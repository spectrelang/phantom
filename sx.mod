entry "./src/main.sx"
version "v0.0.1"
spectre_version "v0.0.16"

build release {
    flags "-release -alt -runtime:hosted"
    output "./phantom"
}

build dev {
    flags "-alt -runtime:hosted"
    output "./phantom-dev"
}
