TERMUX_PKG_HOMEPAGE=https://github.com/protocolbuffers/protobuf
TERMUX_PKG_DESCRIPTION="Protocol buffers C++ library"
# utf8_range is licensed under MIT
TERMUX_PKG_LICENSE="BSD 3-Clause, MIT"
TERMUX_PKG_LICENSE_FILE="LICENSE"
TERMUX_PKG_MAINTAINER="@termux"
# When bumping version:
# - update SHA256 checksum for $_PROTOBUF_ZIP in
#     $TERMUX_SCRIPTDIR/scripts/build/setup/termux_setup_protobuf.sh
# - ALWAYS bump revision of reverse dependencies and rebuild them.
TERMUX_PKG_VERSION=2:24.4
TERMUX_PKG_SRCURL=https://github.com/protocolbuffers/protobuf/archive/v${TERMUX_PKG_VERSION#*:}.tar.gz
TERMUX_PKG_SHA256=616bb3536ac1fff3fb1a141450fa28b875e985712170ea7f1bfe5e5fc41e2cd8
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="abseil-cpp, libc++, zlib"
TERMUX_PKG_BREAKS="libprotobuf-dev, protobuf-static (<< ${TERMUX_PKG_VERSION#*:})"
TERMUX_PKG_REPLACES="libprotobuf-dev"
TERMUX_PKG_FORCE_CMAKE=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dprotobuf_ABSL_PROVIDER=package
-Dprotobuf_BUILD_TESTS=OFF
-DBUILD_SHARED_LIBS=ON
-DCMAKE_INSTALL_LIBDIR=lib
"
TERMUX_PKG_NO_STATICSPLIT=true

termux_step_post_make_install() {
	install -Dm600 -t $TERMUX_PREFIX/share/doc/libutf8-range \
		$TERMUX_PKG_SRCDIR/third_party/utf8_range/LICENSE

	# https://github.com/termux/termux-packages/issues/18002
	local r=$("${READELF}" -sW "${TERMUX_PREFIX}"/lib/libprotobuf.so)
	local s="__emutls_t._ZN6google8protobuf8internal15ThreadSafeArena13thread_cache_E"
	local g=$(echo "${r}" | grep "${s}")
	if [[ -z "${g}" ]]; then
		termux_error_exit "
		Not found symbol: ${s}
		${READELF} output:
		${r}
		"
	fi
}
