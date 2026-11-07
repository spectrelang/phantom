entry "./src/main.sx"
version "v0.0.1"
spectre_version "v0.0.15"

build release {
    flags "-release -alt"
    output "./phantom"
}

build dev {
    flags "-alt"
    output "./phantom-dev"
}
