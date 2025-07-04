import { UUID } from "crypto";
import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken"
import { db } from "../db";
import { users } from "../db/schema";
import { eq } from "drizzle-orm"



export interface AuthRequest extends Request {
    user?: UUID
    token?: string
}

export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {

    // auth middleware token validation check
    try {
        // get the header
        // verify if the token is valid
        // get the user data if the token is valid
        // if no user, return false

        const token = req.header("auth-token")
        if (!token) {
            res.status(401).json({ msg: "No auth token, access denied!" })
            return
        }
        const verified = jwt.verify(token, "passwordKey")
        if (!verified) {
            res.status(401).json({ msg: "Token verification failed!" })
            return
        }

        const verifiedToken = verified as { id: UUID }//extract id from verified object
        const [user] = await db.select().from(users).where(eq(users.id, verifiedToken.id))

        if (!user) {
            res.status(401).json({ msg: "User not found!" })
            return
        }

        req.user = verifiedToken.id
        req.token = token
        next()// everything worked fine, now you can go to next route.

    } catch (e) {
        res.status(500).json({
            accessDenied: false
        })
    }


}