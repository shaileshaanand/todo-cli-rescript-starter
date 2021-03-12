/*
Sample JS implementation of Todo CLI that you can attempt to port:
https://gist.github.com/jasim/99c7b54431c64c0502cfe6f677512a87
*/

/* Returns date with the format: 2021-02-04 */
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
}
  `)

type fsConfig = {encoding: string, flag: string}

/* https://nodejs.org/api/fs.html#fs_fs_existssync_path */
@bs.module("fs") external existsSync: string => bool = "existsSync"

/* https://nodejs.org/api/fs.html#fs_fs_readfilesync_path_options */
@bs.module("fs")
external readFileSync: (string, fsConfig) => string = "readFileSync"

/* https://nodejs.org/api/fs.html#fs_fs_writefilesync_file_data_options */
@bs.module("fs")
external appendFileSync: (string, string, fsConfig) => unit = "appendFileSync"

@bs.module("fs")
external writeFileSync: (string, string, fsConfig) => unit = "writeFileSync"

/* https://nodejs.org/api/os.html#os_os_eol */
@bs.module("os") external eol: string = "EOL"

let encoding = "utf8"

let todoDbPath = "todo.txt"

let todoDoneDbPath = "done.txt"

let showUsageMessage = () => {
  Js.log(`Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`)
}

@bs.module("process")
external exit: int => unit = "exit"

@val @scope("process") external argv: array<string> = "argv"

let notEnoughArgsMsgs = Js.Dict.fromList(list{
  ("add", "Error: Missing todo string. Nothing added!"),
  ("del", "Error: Missing NUMBER for deleting todo."),
  ("done", "Error: Missing NUMBER for marking todo as done."),
})

if !existsSync(todoDbPath) {
  writeFileSync(todoDbPath, "", {encoding: encoding, flag: "w"})
}

if !existsSync(todoDoneDbPath) {
  writeFileSync(todoDoneDbPath, "", {encoding: encoding, flag: "w"})
}

let appendToFile = (filePath, text) =>
  appendFileSync(filePath, text ++ "\n", {encoding: encoding, flag: "a"})

let readLinesFile = filePath =>
  Js.Array.filter(
    todo => todo != "",
    Js.String.split("\n", readFileSync(filePath, {encoding: encoding, flag: "r"})),
  )

let deleteLineFile = (filePath, lineNumber) => {
  let lines = readLinesFile(filePath)
  let line = lines[lineNumber - 1]
  writeFileSync(
    filePath,
    Js.Array.joinWith(
      "\n",
      Js.Array.concat(
        Js.Array.slice(lines, ~start=lineNumber, ~end_=Js.Array.length(lines)),
        Js.Array.slice(lines, ~start=0, ~end_=lineNumber - 1),
      ),
    ),
    {encoding: encoding, flag: "w"},
  )
  line
}

let addTodo = todo => {
  switch todo {
  | Some(todo) =>
    appendToFile(todoDbPath, todo)
    Js.log(`Added todo: "${todo}"`)
  | None => Js.log(notEnoughArgsMsgs->Js.Dict.get("add"))
  }
}

let getTodos = () => readLinesFile(todoDbPath)
let getDone = () => readLinesFile(todoDoneDbPath)

let isValidTodo = todoNum => {
  todoNum >= 1 && todoNum <= Js.Array.length(getTodos())
}

let listTodos = () => {
  let todos = getTodos()

  todos
  ->Belt.Array.reduceWithIndex("", (acc, todo, i) => {
    `[${Belt.Int.toString(i + 1)}] ${todo}\n${acc}`
  })
  ->Js.String.trim
  ->Js.log

  if Js.Array.length(todos) == 0 {
    Js.log("There are no pending todos!")
  }
}

let deleteTodo = todoNum => {
  switch todoNum {
  | Some(todoNum) =>
    if isValidTodo(todoNum) {
      let _ = deleteLineFile(todoDbPath, todoNum)
      Js.log(`Deleted todo #${Belt.Int.toString(todoNum)}`)
    } else {
      Js.log(`Error: todo #${Belt.Int.toString(todoNum)} does not exist. Nothing deleted.`)
    }
  | None => Js.log(notEnoughArgsMsgs->Js.Dict.get("del"))
  }
}

let doneTodo = todoNum => {
  switch todoNum {
  | Some(todoNum) =>
    if isValidTodo(todoNum) {
      let todo = deleteLineFile(todoDbPath, todoNum)
      appendToFile(todoDoneDbPath, `x ${getToday()} ${todo}`)
      Js.log(`Marked todo #${Belt.Int.toString(todoNum)} as done.`)
    } else {
      Js.log(`Error: todo #${Belt.Int.toString(todoNum)} does not exist.`)
    }
  | None => Js.log(notEnoughArgsMsgs->Js.Dict.get("done"))
  }
}

let todoReport = () => {
  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(
        Js.Array.length(getTodos()),
      )} Completed : ${Belt.Int.toString(Js.Array.length(getDone()))}`,
  )
}

let command = argv->Belt.Array.get(2)
let arg = argv->Belt.Array.get(3)
switch command {
| Some(cmd) =>
  switch cmd {
  | "help" => showUsageMessage()
  | "add" => addTodo(arg)
  | "ls" => listTodos()
  | "del" =>
    let todoNum = arg->Belt.Option.flatMap(Belt.Int.fromString)
    deleteTodo(todoNum)
  | "done" =>
    let todoNum = arg->Belt.Option.flatMap(Belt.Int.fromString)
    doneTodo(todoNum)
  | "report" => todoReport()
  | _ => Js.log("Invalid Command!")
  }
| None => showUsageMessage()
}
