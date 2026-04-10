// build.rs

extern crate cc;

use std::env;

fn main() {
    let arch = env::var("CARGO_CFG_TARGET_ARCH").unwrap_or_default();
    let macos = env::var("GELPIA_MACOS").map(|v| v == "1").unwrap_or(false);
    let cpp_stdlib = if macos { "c++" } else { "stdc++" };

    let mut build = cc::Build::new();
    build
        .cpp(true)
        .cpp_link_stdlib(Some(cpp_stdlib))
        .flag("-Wno-strict-aliasing")
        .flag("-O3")
        .flag("-std=c++11")
        .flag("-march=native")
        .flag("-fno-lto")
        .file("src/gaol_wrap.cc");

    if !macos && (arch == "x86" || arch == "x86_64") {
        build.flag("-msse3");
    }

    build.compile("librustgaol.a");
}
