// Generated by ReScript, PLEASE EDIT WITH CARE
'use strict';

var Fs = require("fs");
var Curry = require("bs-platform/lib/js/curry.js");
var Js_dict = require("bs-platform/lib/js/js_dict.js");
var Belt_Int = require("bs-platform/lib/js/belt_Int.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Caml_array = require("bs-platform/lib/js/caml_array.js");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");

var getToday = (function() {
  let date = new Date();
  return new Date(date.getTime() - (date.getTimezoneOffset() * 60000))
    .toISOString()
    .split("T")[0];
});

var encoding = "utf8";

var todo_db_path = "todo.txt";

var todo_done_path = "done.txt";

function show_usage_message(param) {
  console.log("Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics");
  
}

var not_enough_arg_msgs = Js_dict.fromList({
      hd: [
        "add",
        "Error: Missing todo string. Nothing added!"
      ],
      tl: {
        hd: [
          "del",
          "Error: Missing NUMBER for deleting todo."
        ],
        tl: {
          hd: [
            "done",
            "Error: Missing NUMBER for marking todo as done."
          ],
          tl: /* [] */0
        }
      }
    });

if (!Fs.existsSync(todo_db_path)) {
  Fs.writeFileSync(todo_db_path, "", {
        encoding: encoding,
        flag: "w"
      });
}

if (!Fs.existsSync(todo_done_path)) {
  Fs.writeFileSync(todo_done_path, "", {
        encoding: encoding,
        flag: "w"
      });
}

function append_to_file(file_path, text) {
  Fs.appendFileSync(file_path, text + "\n", {
        encoding: encoding,
        flag: "a"
      });
  
}

function read_lines_file(file_path) {
  return Fs.readFileSync(file_path, {
                  encoding: encoding,
                  flag: "r"
                }).split("\n").filter(function (todo) {
              return todo !== "";
            });
}

function delete_line_file(file_path, line_number) {
  var lines = read_lines_file(file_path);
  var line = Caml_array.get(lines, line_number - 1 | 0);
  Fs.writeFileSync(file_path, lines.slice(0, line_number - 1 | 0).concat(lines.slice(line_number, lines.length)).join("\n"), {
        encoding: encoding,
        flag: "w"
      });
  return line;
}

function add_todo(todo) {
  if (todo !== undefined) {
    append_to_file(todo_db_path, todo);
    console.log("Added todo: \"" + todo + "\"");
  } else {
    console.log(Js_dict.get(not_enough_arg_msgs, "add"));
  }
  
}

function get_todos(param) {
  return read_lines_file(todo_db_path);
}

function get_done(param) {
  return read_lines_file(todo_done_path);
}

function is_valid_todo(todo_num) {
  if (todo_num >= 1) {
    return todo_num <= read_lines_file(todo_db_path).length;
  } else {
    return false;
  }
}

function list_todos(param) {
  var todos = read_lines_file(todo_db_path);
  console.log(Belt_Array.reduceWithIndex(todos, "", (function (acc, todo, i) {
                return "[" + String(i + 1 | 0) + "] " + todo + "\n" + acc;
              })).trim());
  if (todos.length === 0) {
    console.log("There are no pending todos!");
    return ;
  }
  
}

function delete_todo(todo_num) {
  if (todo_num !== undefined) {
    if (is_valid_todo(todo_num)) {
      delete_line_file(todo_db_path, todo_num);
      console.log("Deleted todo #" + String(todo_num));
    } else {
      console.log("Error: todo #" + String(todo_num) + " does not exist. Nothing deleted.");
    }
  } else {
    console.log(Js_dict.get(not_enough_arg_msgs, "del"));
  }
  
}

function done_todo(todo_num) {
  if (todo_num !== undefined) {
    if (is_valid_todo(todo_num)) {
      var todo = delete_line_file(todo_db_path, todo_num);
      append_to_file(todo_done_path, "x " + Curry._1(getToday, undefined) + " " + todo);
      console.log("Marked todo #" + String(todo_num) + " as done.");
      return ;
    }
    console.log("Error: todo #" + String(todo_num) + " does not exist.");
    return ;
  }
  console.log(Js_dict.get(not_enough_arg_msgs, "done"));
  
}

function todo_report(param) {
  console.log(Curry._1(getToday, undefined) + " Pending : " + String(read_lines_file(todo_db_path).length) + " Completed : " + String(read_lines_file(todo_done_path).length));
  
}

var command = Belt_Array.get(process.argv, 2);

var arg = Belt_Array.get(process.argv, 3);

if (command !== undefined) {
  switch (command) {
    case "add" :
        add_todo(arg);
        break;
    case "del" :
        delete_todo(Belt_Option.flatMap(arg, Belt_Int.fromString));
        break;
    case "done" :
        done_todo(Belt_Option.flatMap(arg, Belt_Int.fromString));
        break;
    case "help" :
        console.log("Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics");
        break;
    case "ls" :
        list_todos(undefined);
        break;
    case "report" :
        todo_report(undefined);
        break;
    default:
      console.log("Invalid Command!");
  }
} else {
  console.log("Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics");
}

exports.getToday = getToday;
exports.encoding = encoding;
exports.todo_db_path = todo_db_path;
exports.todo_done_path = todo_done_path;
exports.show_usage_message = show_usage_message;
exports.not_enough_arg_msgs = not_enough_arg_msgs;
exports.append_to_file = append_to_file;
exports.read_lines_file = read_lines_file;
exports.delete_line_file = delete_line_file;
exports.add_todo = add_todo;
exports.get_todos = get_todos;
exports.get_done = get_done;
exports.is_valid_todo = is_valid_todo;
exports.list_todos = list_todos;
exports.delete_todo = delete_todo;
exports.done_todo = done_todo;
exports.todo_report = todo_report;
exports.command = command;
exports.arg = arg;
/* not_enough_arg_msgs Not a pure module */
