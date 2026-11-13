entry "./src/main.sx"
version "v0.0.2"
spectre_version "v0.0.17"

build release {
    flags "-release"
    output "./phantom"
}

build dev {
    output "./phantom-dev"
}
