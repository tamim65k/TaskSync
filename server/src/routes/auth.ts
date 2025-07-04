import { Router, Request, Response } from "express"
import { db } from "../db"
import { NewUser, users } from "../db/schema"
import { eq } from "drizzle-orm"
import bcryptjs from "bcryptjs"
import jwt from "jsonwebtoken"
import { auth, AuthRequest } from "../middleware/auth"
import { UUID } from "crypto"


const authRouter = Router()

interface SignUpBody { // benefits of typescript
    name: string,
    email: string,
    password: string,
}

interface LoginBody {
    email: string,
    password: string,
}

authRouter.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {// types given by typescript
    try {
        // get req body
        // check if the user already exist
        // hashing the password
        // create a new user and store in db

        const { name, email, password } = req.body
        const [existingUser] = await db.select().from(users).where(eq(users.email, email))//select all the column of users where emails are matching. []destructuring.
        if (existingUser) {
            res.status(400).json({ msg: "User with the same email already exists." })//send the response then return out of the function
            return // so that it wont create a new user in the db
        }

        const hashedPassword = await bcryptjs.hash(password, 8)
        const newUser: NewUser = {
            name,
            email,
            password: hashedPassword
        }

        const [user] = await db.insert(users).values(newUser).returning()
        res.status(201).json(user)// 200 for ok, 201 for created.
    } catch (e) {
        res.status(500).json({ singupError: e })
    }
})


authRouter.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {// types given by typescript
    try {
        // get req body
        // check if the user already exist
        // hashing the password
        // create a new user and store in db

        const { email, password } = req.body
        const [existingUser] = await db.select().from(users).where(eq(users.email, email))//select all the column of users where emails are matching
        if (!existingUser) {
            res.status(400).json({ msg: "User with this email doesn\'t exists." })//send the response then return out of the function
            return // so that it wont create a new user in the db
        }

        const isMatch = await bcryptjs.compare(password, existingUser.password)
        if (!isMatch) {
            res.status(400).json({ msg: "Invalid Password!" })
        }

        const token = jwt.sign({ id: existingUser.id }, "passwordKey")
        res.json({ token, ...existingUser })// token will be send along the existing user ...spread operator -> which includes all properties of the existinguser object in the new object.
    } catch (e) {
        res.status(500).json({ loginError: e })
    }
})


// token validation check
authRouter.post("/tokenIsValid", async (req, res) => {
    try {
        // get the header
        // verify if the token is valid
        // get the user data if the token is valid
        // if no user, return false

        const token = req.header("auth-token")
        if (!token) {
            res.json(false)
            return
        }
        const verified = jwt.verify(token, "passwordKey")
        if (!verified) {
            res.json(false)
            return
        }

        const verifiedToken = verified as { id: string }//extract id from verified object
        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id))

        if (!user) {
            res.json(false)
            return
        }
        res.json(true)
    } catch (e) {
        res.status(500).json({
            accessDenied: false
        })
    }
})



authRouter.get("/", auth, async (req: AuthRequest, res) => {
    try {
        if (!req.user) {
            res.status(401).json({ msg: "User not found!" })
        }

        const [user] = await db.select().from(users).where(eq(users.id, req.user as UUID))
        res.json({ ...user, token: req.token })

    } catch (e) {
        res.status(500).json({msg: 'An unknow error occured'})
    }
})

export default authRouter