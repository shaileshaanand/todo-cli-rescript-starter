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
  switch todo {
  | Some(todo) =>
    append_to_file(todo_db_path, todo)
    Js.log(`Added todo: "${todo}"`)
  | None => Js.log(not_enough_arg_msgs->Js.Dict.get("add"))
  }
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
  switch todo_num {
  | Some(todo_num) =>
    if is_valid_todo(todo_num) {
      let _ = delete_line_file(todo_db_path, todo_num)
      Js.log(`Deleted todo #${Belt.Int.toString(todo_num)}`)
    } else {
      Js.log(`Error: todo #${Belt.Int.toString(todo_num)} does not exist. Nothing deleted.`)
    }
  | None => Js.log(not_enough_arg_msgs->Js.Dict.get("del"))
  }
}

let done_todo = todo_num => {
  switch todo_num {
  | Some(todo_num) =>
    if is_valid_todo(todo_num) {
      let todo = delete_line_file(todo_db_path, todo_num)
      append_to_file(todo_done_path, `x ${getToday()} ${todo}`)
      Js.log(`Marked todo #${Belt.Int.toString(todo_num)} as done.`)
    } else {
      Js.log(`Error: todo #${Belt.Int.toString(todo_num)} does not exist.`)
    }
  | None => Js.log(not_enough_arg_msgs->Js.Dict.get("done"))
  }
}

let todo_report = () => {
  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(
        Js.Array.length(get_todos()),
      )} Completed : ${Belt.Int.toString(Js.Array.length(get_done()))}`,
  )
}

let command = argv->Belt.Array.get(2)
let arg = argv->Belt.Array.get(3)
switch command {
| Some(cmd) =>
  switch cmd {
  | "help" => show_usage_message()
  | "add" => add_todo(arg)
  | "ls" => list_todos()
  | "del" =>
    let todo_num = arg->Belt.Option.flatMap(Belt.Int.fromString)
    delete_todo(todo_num)
  | "done" =>
    let todo_num = arg->Belt.Option.flatMap(Belt.Int.fromString)
    done_todo(todo_num)
  | "report" => todo_report()
  | _ => Js.log("Invalid Command!")
  }
| None => show_usage_message()
}
