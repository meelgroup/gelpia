# Global Extrema Locator Parallelization for Interval Arithmetic

## Gelpia algorithm
Gelpia is a cooperative,
[interval-arithmetic](https://en.wikipedia.org/wiki/Interval_arithmetic)
branch-and-bound based algorithm (IBBA).
It rigorously finds an upper bound on the global maximum of a multivariate
function on a given interval.
This means that its answer is guaranteed to be above the global maximum on the
interval when evaluated using real arithmetic.
Gelpia is a ***cooperative*** solver in the sense that we concurrently run fast,
approximate algorithms which find local maxima to inform the IBBA of new lower
bounds.
This causes the IBBA to refocus its attention on more promising regions of the
search space.
Meanwhile, the IBBA informs the cooperative algorithms of the search space
currently being explored to keep them focused on trying to find the global
maximum.
We have found that this bi-directional communication significantly reduces
runtime, allowing us to handle functions with many variables.


## Building
Gelpia now has separate native build setups for Linux and macOS.
Linux remains the primary build path, and macOS builds use `make MACOS=1`.

* Requirements:
	* Not included:
		* python3
			* sly
		* bison
		* flex
		* c++ compiler
		* c compiler
		* wget
	* Included:
		* rust
		* gaol
		* crlibm

### Linux

Install the system dependencies first, then build the bundled native
requirements:

    python -m pip install --upgrade pip
    pip install sly
    sudo apt install flex bison wget
    make requirements
    make

For building the requirements by hand see _documents/BuildingRequirements.md_.

### macOS

Install the build tools with Homebrew, build the native requirements with the
macOS helper script, then compile Gelpia with the macOS make flag:

    python -m pip install --upgrade pip
    pip install sly
    brew install bison flex wget
    bash .github/scripts/build-macos-requirements.sh
    make MACOS=1

Both build paths run Rust's cargo build system and install the frontend files
into `bin/` for execution.


## Using
Gelpia may then be ran, it is an executable `gelpia` in the `bin` directory.
It has a built in help system for argument clarification.
A query function can be specified either on the command line or via a query file.
Syntax for a query file can be found in _documents/QueryFormat.md_.
When ran gelpia outputs an upper and lower bound of the requested extrema.



## Testing/Benchmarking
A benchmarking system for Gelpia is located at
[https://github.com/soarlab/gelpia_tests.git](https://github.com/soarlab/gelpia_tests.git).


#### Example uses:

    > ./bin/gelpia --function "x=[1,10]; y=[5,15]; x^2 + x*y + y*sin(x/10)"
    Maximum lower bound 262.6220647721184
    Maximum upper bound 262.6220647721185

The default mode is to find the maximum, but this can be changed with the
`--mode` argument.

    > ./bin/gelpia --function "x=[1,10]; y=[5,15]; x^2 + x*y + y*sin(x/10)" --mode=min
    Minimum lower bound 6.499167083234139
    Minimum upper bound 6.499167083234142
    > ./bin/gelpia --function "x=[1,10]; y=[5,15]; x^2 + x*y + y*sin(x/10)" --mode=min-max
    Minimum lower bound 6.499167083234139
    Minimum upper bound 6.499167083234142
    Maximum lower bound 262.6220647721184
    Maximum upper bound 262.6220647721185


## Authors
Gelpia is authored by Mark S. Baranowski and Ian Briggs
