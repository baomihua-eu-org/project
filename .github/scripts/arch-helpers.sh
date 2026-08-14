#!/usr/bin/env bash
# ── BaoMiHua 发布文件命名规范 ────────────────────────────────────────
# 所有 release 资产统一命名：bmh-<os>-<arch>[-<libc>]-<product>.<ext>
#   product: cli / gui-App（GUI 一律 gui-App）
#   libc: 仅 linux 输出（gnu/musl），windows/macos/android/ios 不输出
# 例如：bmh-windows-x86_64-gui-App.exe.zip、bmh-linux-x86_64-gnu-cli.zip
# 该命名是自动升级（官网 catalog 匹配）的唯一契约，修改前必须同步
# 修改 cf-website/functions/lib/releases.ts 中的前缀匹配逻辑。

baomihua_normalize_arch() {
  local arch_raw="${1:-}"

  case "${arch_raw}" in
    x86_64)
      printf '%s\n' "x86_64"
      ;;
    i686)
      printf '%s\n' "x86_32"
      ;;
    aarch64|arm64)
      printf '%s\n' "aarch64"
      ;;
    *)
      printf '%s\n' "${arch_raw}"
      ;;
  esac
}

baomihua_build_base() {
  local os="${1:-}"
  local arch="${2:-}"
  local libc="${3:-}"
  local product="${4:-}"

  local name="bmh-${os}-${arch}"
  if [[ "${os}" == "linux" && -n "${libc}" ]]; then
    name="${name}-${libc}"
  fi
  printf '%s\n' "${name}-${product}"
}

baomihua_detect_os_default() {
  local target="${1:-}"

  if [[ "${target}" == *windows* ]]; then
    printf '%s\n' "windows"
  elif [[ "${target}" == *apple-darwin* ]]; then
    printf '%s\n' "macos"
  elif [[ "${target}" == *linux-android* ]]; then
    printf '%s\n' "android"
  elif [[ "${target}" == *linux* ]]; then
    printf '%s\n' "linux"
  else
    printf '%s\n' "unknown"
  fi
}

baomihua_detect_libc_default() {
  local target="${1:-}"

  if [[ "${target}" == *musl* ]]; then
    printf '%s\n' "musl"
  elif [[ "${target}" == *gnu* ]]; then
    printf '%s\n' "gnu"
  elif [[ "${target}" == *msvc* ]]; then
    printf '%s\n' "msvc"
  elif [[ "${target}" == *darwin* ]]; then
    printf '%s\n' "darwin"
  elif [[ "${target}" == *android* ]]; then
    printf '%s\n' "android"
  else
    printf '%s\n' "native"
  fi
}

baomihua_detect_os_gui() {
  local target="${1:-}"

  if [[ "${target}" == *windows* ]]; then
    printf '%s\n' "windows"
  elif [[ "${target}" == *apple-darwin* ]]; then
    printf '%s\n' "macos"
  elif [[ "${target}" == *linux* ]]; then
    printf '%s\n' "linux"
  else
    printf '%s\n' "unknown"
  fi
}

baomihua_detect_libc_gui() {
  local target="${1:-}"

  if [[ "${target}" == *musl* ]]; then
    printf '%s\n' "musl"
  elif [[ "${target}" == *gnu* ]]; then
    printf '%s\n' "gnu"
  elif [[ "${target}" == *msvc* ]]; then
    printf '%s\n' "msvc"
  elif [[ "${target}" == *darwin* ]]; then
    printf '%s\n' "darwin"
  else
    printf '%s\n' "native"
  fi
}

baomihua_cli_base() {
  local target="${1:-}"
  local variant="${2:-default}"
  local arch

  arch="$(baomihua_normalize_arch "${target%%-*}")"

  case "${variant}" in
    default)
      baomihua_build_base "$(baomihua_detect_os_default "${target}")" "${arch}" "$(baomihua_detect_libc_default "${target}")" "cli"
      ;;
    android)
      baomihua_build_base "android" "${arch}" "" "termux-cli"
      ;;
    *)
      printf 'Unknown cli base variant: %s\n' "${variant}" >&2
      return 1
      ;;
  esac
}

baomihua_gui_base() {
  local target="${1:-}"
  local variant="${2:-default}"
  local arch

  arch="$(baomihua_normalize_arch "${target%%-*}")"

  case "${variant}" in
    default)
      baomihua_build_base "$(baomihua_detect_os_gui "${target}")" "${arch}" "$(baomihua_detect_libc_gui "${target}")" "gui-App"
      ;;
    android)
      baomihua_build_base "android" "${arch}" "" "gui-App"
      ;;
    ios-app)
      baomihua_build_base "ios" "${arch}" "" "gui-App"
      ;;
    *)
      printf 'Unknown gui base variant: %s\n' "${variant}" >&2
      return 1
      ;;
  esac
}
