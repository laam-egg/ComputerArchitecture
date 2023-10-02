# MIPS Programming (using SPIM)

# Development Environment Setup

### Linux

```sh
sudo apt install spim
```

## Compiling and Running MIPS programs
```sh
$		spim
(spim)		load "hello.s"
(spim)		run
(spim)		run
(spim)		print $a0
(spim)		
(spim)		reinitialize
(spim)		load "hello.s"
(spim)		run
(spim)
(spim)		exit
$
```

## Syscalls
<https://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html>

Residence of values:

|   System Call Code    |                    Parameters                   |
| :-------------------: | :---------------------------------------------: |
|          $v0          | Integers: $a0 - $a3; Floats/Doubles: $f0 - $f12 |

Some system call codes:

| `$v0` |  System call  |                    Parameters                   | Return Value |
| ----: | :------------ | :---------------------------------------------- | :----------: |
|    10 | exit          |                         -                       |       -      |
|    17 | exit2         | int $a0 (return value ignored by MARS)          |       -      |
|     1 | print integer | int $a0                                         |       -      |
|     2 | print float   | float $f12                                      |       -      |
|     3 | print double  | double $f12                                     |       -      |
|     4 | print string  | null-terminated string (NTS) address $a0        |       -      |
|    11 | print char    | char $a0                                        |       -      |
|     5 | read integer  |                         -                       | int $v0      |
|     6 | read float    |                         -                       | float $f0    |
|     7 | read double   |                         -                       | double $f0   |
|     8 | read string   | buffer string address $a0, `size_t` $a1         | NTS addr $a0 |
|    12 | read char     |                         -                       | char $v0     |

## File Descriptors (fd)

	0: stdin
	1: stdout
	2: stderr

