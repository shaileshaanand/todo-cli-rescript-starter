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

let todo_db_path = "todo.txt"

let todo_done_path = "done.txt"

let show_usage_message = () => {
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

let not_enough_arg_msgs = Js.Dict.fromList(list{
  ("add", "Error: Missing todo string. Nothing added!"),
  ("del", "Error: Missing NUMBER for deleting todo."),
  ("done", "Error: Missing NUMBER for marking todo as done."),
})

if !existsSync(todo_db_path) {
  writeFileSync(todo_db_path, "", {encoding: encoding, flag: "w"})
}

if !existsSync(todo_done_path) {
  writeFileSync(todo_done_path, "", {encoding: encoding, flag: "w"})
}

let append_to_file = (file_path, text) =>
  appendFileSync(file_path, text ++ "\n", {encoding: encoding, flag: "a"})

let read_lines_file = file_path =>
  Js.Array.filter(
    todo => todo != "",
    Js.String.split("\n", readFileSync(file_path, {encoding: encoding, flag: "r"})),
  )

let delete_line_file = (file_path, line_number) => {
  let lines = read_lines_file(file_path)
  let line = lines[line_number - 1]
  writeFileSync(
    file_path,
    Js.Array.joinWith(
      "\n",
      Js.Array.concat(
        Js.Array.slice(lines, ~start=line_number, ~end_=Js.Array.length(lines)),
        Js.Array.slice(lines, ~start=0, ~end_=line_number - 1),
      ),
    ),
    {encoding: encoding, flag: "w"},
  )
  line
}

let add_todo = todo => {
  append_to_file(todo_db_path, todo)
  Js.log(`Added todo: "${todo}"`)
}

let get_todos = () => read_lines_file(todo_db_path)
let get_done = () => read_lines_file(todo_done_path)

let is_valid_todo = todo_num => {
  todo_num >= 1 && todo_num <= Js.Array.length(get_todos())
}

let list_todos = () => {
  let todos = get_todos()
  if Js.Array.length(todos) == 0 {
    Js.log("There are no pending todos!")
  } else {
    for i in Js.Array.length(todos) downto 1 {
      Js.log(`[${Belt.Int.toString(i)}] ${todos[i - 1]}`)
    }
  }
}

let delete_todo = todo_num => {
  if is_valid_todo(todo_num) {
    let _ = delete_line_file(todo_db_path, todo_num)
    Js.log(`Deleted todo #${Belt.Int.toString(todo_num)}`)
  } else {
    Js.log(`Error: todo #${Belt.Int.toString(todo_num)} does not exist. Nothing deleted.`)
  }
}

let done_todo = todo_num => {
  if is_valid_todo(todo_num) {
    let todo = delete_line_file(todo_db_path, todo_num)
    append_to_file(todo_done_path, `x ${getToday()} ${todo}`)
    Js.log(`Marked todo #${Belt.Int.toString(todo_num)} as done.`)
  } else {
    Js.log(`Error: todo #${Belt.Int.toString(todo_num)} does not exist.`)
  }
}

let todo_report = () => {
  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(
        Js.Array.length(get_todos()),
      )} Completed : ${Belt.Int.toString(Js.Array.length(get_done()))}`,
  )
}

let args = Js.Array.slice(argv, ~start=2, ~end_=Js.Array.length(Sys.argv))

if Js.Array.length(args) == 0 {
  show_usage_message()
} else {
  let command = args[0]
  if Js.Array.includes(command, ["add", "del", "done"]) && Js.Array.length(args) != 2 {
    Js.log(Js.Dict.get(not_enough_arg_msgs, command))
    exit(0)
  }
  switch command {
  | "help" => show_usage_message()
  | "add" => add_todo(args[1])
  | "ls" => list_todos()
  | "del" =>
    switch Belt.Int.fromString(args[1]) {
    | None => Js.log("Input Error!")
    | Some(todo_num) => delete_todo(todo_num)
    }
  | "done" =>
    switch Belt.Int.fromString(args[1]) {
    | None => Js.log("Input Error!")
    | Some(todo_num) => done_todo(todo_num)
    }
  | "report" => todo_report()
  | _ => Js.log("Invalid Command!")
  }
}
