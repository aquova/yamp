# Maintainer: aquova <mail at aquova dot net>
pkgname="yamp-git"
pkgver=r10.403804a
pkgrel=1
pkgdesc="Yet Another Markdown Parser"
url="https://github.com/aquova/yamp"
arch=("x86_64")
depends=('nim')
source=("git+${url}.git")
sha256sums=("SKIP")

pkgver() {
    cd $srcdir/yamp
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    cd $srcdir/yamp
    nim c -d:release yamp
}

package() {
    cd $srcdir/yamp
    mkdir -p "$pkgdir/usr/bin"
    install -Dm755 yamp "$pkgdir/usr/bin"
}
