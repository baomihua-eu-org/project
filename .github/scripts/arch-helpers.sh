#!/usr/bin/env bash
# ── BaoMiHua 发布文件命名规范 ────────────────────────────────────────
# 所有 release 资产统一命名：BaoMiHua-<kind>-<arch>-<os>-<libc>.<ext>
# 该命名是自动升级（官网 catalog 匹配）的唯一契约，修改前必须同步
# 修改 cf-website/app/lib/github-releases.ts 中的前缀匹配逻辑。

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
  local product="${1:-}"
  local arch="${2:-}"
  local os="${3:-}"
  local libc="${4:-}"

  printf '%s\n' "BaoMiHua-${product}-${arch}-${os}-${libc}"
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

baomihua_detect_linux_package_libc() {
  local target="${1:-}"

  if [[ "${target}" == *musl* ]]; then
    printf '%s\n' "musl"
  elif [[ "${target}" == *gnu* ]]; then
    printf '%s\n' "gnu"
  else
    printf '%s\n' "linux"
  fi
}

baomihua_cli_base() {
  local target="${1:-}"
  local variant="${2:-default}"
  local arch

  arch="$(baomihua_normalize_arch "${target%%-*}")"

  case "${variant}" in
    default)
      baomihua_build_base "cli" "${arch}" "$(baomihua_detect_os_default "${target}")" "$(baomihua_detect_libc_default "${target}")"
      ;;
    android)
      baomihua_build_base "cli" "${arch}" "android" "cli"
      ;;
    linux-packages)
      baomihua_build_base "cli" "${arch}" "linux" "$(baomihua_detect_linux_package_libc "${target}")"
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
      baomihua_build_base "gui" "${arch}" "$(baomihua_detect_os_gui "${target}")" "$(baomihua_detect_libc_gui "${target}")"
      ;;
    windows-msvc)
      baomihua_build_base "gui" "${arch}" "windows" "msvc"
      ;;
    android)
      baomihua_build_base "gui" "${arch}" "android" "app"
      ;;
    ios-app)
      baomihua_build_base "gui" "${arch}" "ios" "app"
      ;;
    macos-app)
      baomihua_build_base "gui" "${arch}" "macos" "app"
      ;;
    *)
      printf 'Unknown gui base variant: %s\n' "${variant}" >&2
      return 1
      ;;
  esac
}
