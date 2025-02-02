# Keyboard Layout Analyzer & Generator

This is Nim port of the keyboard analyzer from [GULAG](https://github.com/RusDoomer/GULAG) for English ANSI keyboards.

Currently a work in progress (WIP). Not all features are implemented yet. The current intent is NOT to run on the GPU.

The GULAG analyzer is a base starting point with plans to implement various features that will diverge significantly from that project, simply based on my own desires and preferences.

This project is a sandbox to play.

## TODO
- Alternate fingerings (anglemod, etc..)
- African Buffalo Optimization
- Multiple language support
- Multiple keyboard support (colstag, rowstag, ortho)
- Desktop GUI (maybe)

## To compile and run with optomizations

```sh
nimble run -d:release --opt:speed -d:danger --passL:-s --cc:clang --mm:arc
```

That is all.