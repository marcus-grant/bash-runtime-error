#!/bin/bash

###### Error Codes
ERROR_DEFAULT=1           # Conventional general error
ERROR_MISUSE_OF_BUILTINS=2 # Conventional error involved with misuse of builtins
ERROR_INCORRECT_ARG=3     # Needs to be run without args or with a correct one

ERROR_NO_CONFIGS_DIR=10    # For this to work there needs to be a configs dir
ERROR_VAR_NOT_FOUND=11     # Failure code for an unfound variable
ERROR_MISUSE_OF_FUNC=12    # When misusing functions' args, this comes up

ERROR_TEST_CASE_FAIL=100    # Exit code for any failed test case

# helper function to the above runtime-error function that prints out the--
#--final exit message, for the sake of reuse of a very long prompt
# if an argument is given, which is the exit code, use it
# otherwise check the global var error_code, use it
# finally if neither exist, give a default exit
function runtime-error-exiting-message()
{
  # if number of arguments > 1, then this function is being misused, exit as such
  if (( $# > 1 )); then
    echo "[RUNTIME_ERROR]runtime-error-exit-and-message"
    echo "error_message:"
    echo "The named function, has an incorrect argument count."
    error_code=$ERROR_INCORRECT_ARG
  fi
  echo ""
  echo "Please copy & paste this RUNTIME_ERROR message into the issues section of the github repository."
  echo "The developer will patch it as quickly as possible, and you'll get positive notice on your github account for raising the issue."
  echo "The github reposity issues section of this script is located here:"
  echo "https://github.com/marcus-grant/kitchen-vim/issues"
  echo "exiting script without completion, sorry, please bear with us...."
  if (( $# == 1 )); then
    exit $1;
  elif [ ! -z ${error_code} ]; then
    exit $error_code;
  fi

  # if no error_code was provided, exit with the default
  exit 1;
}

# function to exit program with a runtime error prompt based on argument semantics
# arguments, if present, have these purposes:
# $3 -- error_code
# $2 -- error_message
# $1 -- error_function
# n/a-- check for global variables, if neither error_code, nor, error_function, nor error_message--
#--are used, then send a default runtime message
function runtime-error()
{
  # every runtime-error will have this in its message
  echo ""
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

  # if arguments are provided, they get semantic priority
  # provide an exit with messages based on them
  if (( $# == 3 )); then
    echo "[RUNTIME_ERROR]function: $1"
    echo "error_code: $3"
    echo "error_message:"
    echo "$2"
    runtime-error-exiting-message $3
  fi

  # now we're in the condition where we aren't provided an error code as an arg
  # provide the default error code
  if (( $# == 2)); then
    echo "[RUNTIME_ERROR]function: $1"
    echo "error_code: $ERROR_DEFAULT (DEFAULT_CODE)"
    echo "error_message:"
    echo "$2"
    runtime-error-exiting-message

    # now we only have the function where the error occurs, exit with default code
    # -- and default error message
  elif (( $# == 1)); then
    echo "[RUNTIME_ERROR]function: $1"
    echo "error_code: $ERROR_DEFAULT (DEFAULT_CODE)"
    echo "error_message: N/A"
    runtime-error-exiting-message

    # now handle the case where this function's arguments are misused
  elif (( $# > 3)); then
    echo "[RUNTIME_ERROR]function: runtime-error"
    echo "error_message:"
    echo "The runtime-error function is using > 3 args can't execute it properly. This is an error within a runtime error, so be sure to address the error that triggered this function in the first place."
    runtime-error-exiting-message $ERROR_INCORRECT_ARG
  fi

  # now every case where arguments are provided is handled
  # moving on to cases where global variables may have been used

  # now addressing each global variable involved in runtime-errors
  # this sequence of conditionals deal with existense of variable: error_function
  if [ ! -z ${error_function} ]; then
    echo "[RUNTIME_ERROR]function: $error_function"
  else
    echo "[RUNTIME_ERROR]function: N/A"
  fi

  if [ ! -z ${error_message} ]; then
    echo "error_message:"
    echo "$error_message"
  else
    echo "error_message: N/A"
  fi

  if [ ! -z ${error_code} ]; then
    runtime-error-exiting-message $error_code
  fi
  runtime-error-exiting-message
}



# unit testing

function unit-test0() { # works
  echo "unit test 0:"
  echo "all three args given"
  runtime-error "unit-test0" "error msg... error_code=$ERROR_VAR_NOT_FOUND" $ERROR_VAR_NOT_FOUND
}

function unit-test1() { # works
  echo "unit test 1:"
  echo "test runtime-error with args for error message and error func"
  runtime-error "unit-test1" "error msg... error_code=1 (default)"
}

function unit-test2() { # works
  echo "unit test 2:"
  echo "test runtime-error with args only function creating error"
  runtime-error "unit-test2"
}

function unit-test3() { # works -- TODO: could be better, should throw an error for the error based on type, but it'll do
  echo "unit test 3:"
  echo "test runtime-error with functon args for incorrect dataype on error code"
  runtime-error "unit-test2" "wrong argument data type for error code" "not an int"
}

function unit-test4() { # works
  echo "unit test 4:"
  echo "test runtime-error with too many arguments"
  runtime-error "unit-test4" "too many arguments sent to function" $ERROR_INCORRECT_ARG "one too many args"
}

#### enough argument testing for now, let's handle logic for global variables

function unit-test10() { # TODO: fails, interpreter says "line 101: [: too many arguments"
  echo "unit test 10:"
  echo "test running with only global vars for runtime-error, with no previous values"
  error_function="unit-test10"
  error_message="should correctly display error with function it's called from, with this message, and error code $ERROR_DEFAULT (default)"
  error_code=$ERROR_DEFAULT
  runtime-error
}

# check for '-t' argument to run TEST_CASE_FAILURE
# argument after t is a number from 0 to ...
# that number represents the unit test to run
# test runtime-error function
function error-unit-testing() {
  "unit-test$1"
}

if (( $# == 2 )); then # check for correct number of args to test
  if [ "$1" == "-t" ]; then # check for option to indicate testing
    if (( $2 >= 0 )); then # check for valid unit test number
      error-unit-testing $2 # pass as numbr of unit test to use
    fi
  fi
fi
