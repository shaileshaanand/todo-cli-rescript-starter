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

var todoDbPath = "todo.txt";

var todoDoneDbPath = "done.txt";

function showUsageMessage(param) {
  console.log("Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics");
  
}

var notEnoughArgsMsgs = Js_dict.fromList({
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

if (!Fs.existsSync(todoDbPath)) {
  Fs.writeFileSync(todoDbPath, "", {
        encoding: encoding,
        flag: "w"
      });
}

if (!Fs.existsSync(todoDoneDbPath)) {
  Fs.writeFileSync(todoDoneDbPath, "", {
        encoding: encoding,
        flag: "w"
      });
}

function appendToFile(filePath, text) {
  Fs.appendFileSync(filePath, text + "\n", {
        encoding: encoding,
        flag: "a"
      });
  
}

function readLinesFile(filePath) {
  return Fs.readFileSync(filePath, {
                  encoding: encoding,
                  flag: "r"
                }).split("\n").filter(function (todo) {
              return todo !== "";
            });
}

function deleteLineFile(filePath, lineNumber) {
  var lines = readLinesFile(filePath);
  var line = Caml_array.get(lines, lineNumber - 1 | 0);
  Fs.writeFileSync(filePath, lines.slice(0, lineNumber - 1 | 0).concat(lines.slice(lineNumber, lines.length)).join("\n"), {
        encoding: encoding,
        flag: "w"
      });
  return line;
}

function addTodo(todo) {
  if (todo !== undefined) {
    appendToFile(todoDbPath, todo);
    console.log("Added todo: \"" + todo + "\"");
  } else {
    console.log(Js_dict.get(notEnoughArgsMsgs, "add"));
  }
  
}

function getTodos(param) {
  return readLinesFile(todoDbPath);
}

function getDone(param) {
  return readLinesFile(todoDoneDbPath);
}

function isValidTodo(todoNum) {
  if (todoNum >= 1) {
    return todoNum <= readLinesFile(todoDbPath).length;
  } else {
    return false;
  }
}

function listTodos(param) {
  var todos = readLinesFile(todoDbPath);
  console.log(Belt_Array.reduceWithIndex(todos, "", (function (acc, todo, i) {
                return "[" + String(i + 1 | 0) + "] " + todo + "\n" + acc;
              })).trim());
  if (todos.length === 0) {
    console.log("There are no pending todos!");
    return ;
  }
  
}

function deleteTodo(todoNum) {
  if (todoNum !== undefined) {
    if (isValidTodo(todoNum)) {
      deleteLineFile(todoDbPath, todoNum);
      console.log("Deleted todo #" + String(todoNum));
    } else {
      console.log("Error: todo #" + String(todoNum) + " does not exist. Nothing deleted.");
    }
  } else {
    console.log(Js_dict.get(notEnoughArgsMsgs, "del"));
  }
  
}

function doneTodo(todoNum) {
  if (todoNum !== undefined) {
    if (isValidTodo(todoNum)) {
      var todo = deleteLineFile(todoDbPath, todoNum);
      appendToFile(todoDoneDbPath, "x " + Curry._1(getToday, undefined) + " " + todo);
      console.log("Marked todo #" + String(todoNum) + " as done.");
      return ;
    }
    console.log("Error: todo #" + String(todoNum) + " does not exist.");
    return ;
  }
  console.log(Js_dict.get(notEnoughArgsMsgs, "done"));
  
}

function todoReport(param) {
  console.log(Curry._1(getToday, undefined) + " Pending : " + String(readLinesFile(todoDbPath).length) + " Completed : " + String(readLinesFile(todoDoneDbPath).length));
  
}

var command = Belt_Array.get(process.argv, 2);

var arg = Belt_Array.get(process.argv, 3);

if (command !== undefined) {
  switch (command) {
    case "add" :
        addTodo(arg);
        break;
    case "del" :
        deleteTodo(Belt_Option.flatMap(arg, Belt_Int.fromString));
        break;
    case "done" :
        doneTodo(Belt_Option.flatMap(arg, Belt_Int.fromString));
        break;
    case "help" :
        console.log("Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics");
        break;
    case "ls" :
        listTodos(undefined);
        break;
    case "report" :
        todoReport(undefined);
        break;
    default:
      console.log("Invalid Command!");
  }
} else {
  console.log("Usage :-\n$ ./todo add \"todo item\"  # Add a new todo\n$ ./todo ls               # Show remaining todos\n$ ./todo del NUMBER       # Delete a todo\n$ ./todo done NUMBER      # Complete a todo\n$ ./todo help             # Show usage\n$ ./todo report           # Statistics");
}

exports.getToday = getToday;
exports.encoding = encoding;
exports.todoDbPath = todoDbPath;
exports.todoDoneDbPath = todoDoneDbPath;
exports.showUsageMessage = showUsageMessage;
exports.notEnoughArgsMsgs = notEnoughArgsMsgs;
exports.appendToFile = appendToFile;
exports.readLinesFile = readLinesFile;
exports.deleteLineFile = deleteLineFile;
exports.addTodo = addTodo;
exports.getTodos = getTodos;
exports.getDone = getDone;
exports.isValidTodo = isValidTodo;
exports.listTodos = listTodos;
exports.deleteTodo = deleteTodo;
exports.doneTodo = doneTodo;
exports.todoReport = todoReport;
exports.command = command;
exports.arg = arg;
/* notEnoughArgsMsgs Not a pure module */
