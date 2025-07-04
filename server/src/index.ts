import express from "express"
import authRouter from "./routes/auth"
import taskRouter from "./routes/task"

const app = express()


// below line is like a global middleWare
app.use(express.json())// take a look at all the incoming requests and pass only json data.
app.use("/auth", authRouter)// whenever we want to add a middleware/routing with /auth prefix
app.use("/task", taskRouter)

// a simple rest api
app.get("/", (req, res) => {
    res.send("Welcome to my app!..!")
})

app.listen(8000, () => {
    console.log("Server started on port 8000")
})