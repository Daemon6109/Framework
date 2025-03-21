# Errors

If you come across an error, you should be able to find it here. If not, [file an issue](https://github.com/Daemon6109/Framework/issues) because it's unintentional.

## `ALREADY_STARTED`

The framework has already started, you cannot create any new providers, create new hooks, add paths, or run `start` again.

## `FATAL_INIT`

An `init` function errored somewhere, the message is provided in the error.

## `FATAL_ADD_MODULE`

There was an issue adding the module to the load stack, which means a simple `require` caused an error.

## `INVALID_TYPE`

The type you are passing to a parameter of some sort is invalid.