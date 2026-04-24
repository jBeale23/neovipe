#!/bin/sh

SCRIPT_DIR=$(cd -- "$(dirname -- "${0}")" && pwd)
NEOVIPE_PATH="$(dirname -- "${SCRIPT_DIR}")/nvipe"

assert_eq_str() {
  if [ "${1}" = "${2}" ]; then
    return 0
  fi
  return 1
}

assert_eq_num() {
  if [ "${1}" -eq "${2}" ]; then
    return 0
  fi
  return 1
}

editing() {
  total_tests=$((total_tests + 1))
  total_subtests=0
  failed_subtests=0
  printf "INFO: Running Editing Test.\n"

  result=$(printf "Please save without editing this text.\n" | "${NEOVIPE_PATH}")
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_str "${result}" "Please save without editing this text."; then
    failed_subtests=$((failed_subtests + 1))
  fi

  result=$(printf "Please delete this text, and then save.\n" | "${NEOVIPE_PATH}")
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_str "${result}" ""; then
    failed_subtests=$((failed_subtests + 1))
  fi

  result=$(printf "Please exit without saving.\n" | "${NEOVIPE_PATH}" --pipe-without-save)
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_str "${result}" "Please exit without saving."; then
    failed_subtests=$((failed_subtests + 1))
  fi

  if ! assert_eq_num "${failed_subtests}" 0; then
    printf "Failed %s subtests of %s.\n" "${failed_subtests}" "${total_subtests}" >&2
    return 1
  fi

}

cleanup() {
  trap '' EXIT HUP INT QUIT ABRT TERM
  printf "INFO: Cleaning Up Saturation Test.\n"
  printf "INFO: This may take some time...\n"
  awk 'BEGIN {
      charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      len = length(charset)
      for (i = 1; i <= len; i++) {
          for (j = 1; j <= len; j++) {
              for (k = 1; k <= len; k++) {
                  print substr(charset, i, 1) substr(charset, j, 1) substr(charset, k, 1)
              }
          }
      }
  }' | while read -r line; do
    rm -f "${TMPDIR:-/tmp}/${line}" 2> /dev/null
  done
}

# WARNING: This test is extremely long compared to all of the others.
# This uses a saturation attack to test NeoVipe's defense against the injection of malicious
# information and requires the creation and destruction of ~240k temporary files.
saturation() {
  total_tests=$((total_tests + 1))
  total_subtests=0
  failed_subtests=0
  printf "INFO: Running Saturation Test.\n"
  printf "INFO: This may take some time...\n"

  awk 'BEGIN {
      charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      len = length(charset)
      for (i = 1; i <= len; i++) {
          for (j = 1; j <= len; j++) {
              for (k = 1; k <= len; k++) {
                  print substr(charset, i, 1) substr(charset, j, 1) substr(charset, k, 1)
              }
          }
      }
  }' | while read -r line; do
    touch "${TMPDIR:-/tmp}/${line}"
  done
  trap 'cleanup' EXIT HUP INT QUIT ABRT TERM
  "${NEOVIPE_PATH}" -t XXX 2> /dev/null
  status="$?"
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_num "${status}" 111; then
    failed_subtests=$((failed_subtests + 1))
  fi

  if ! assert_eq_num "${failed_subtests}" 0; then
    printf "Failed %s subtests of %s.\n" "${failed_subtests}" "${total_subtests}" >&2
    return 1
  fi
}

exit_status() {
  total_tests=$((total_tests + 1))
  total_subtests=0
  failed_subtests=0
  printf "INFO: Running Exit Status Test.\n"

  "${NEOVIPE_PATH}" --an-invalid-long-option 2> /dev/null
  status="$?"
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_num "${status}" 2; then
    failed_subtests=$((failed_subtests + 1))
  fi

  "${NEOVIPE_PATH}" -i 2> /dev/null
  status="$?"
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_num "${status}" 2; then
    failed_subtests=$((failed_subtests + 1))
  fi

  "${NEOVIPE_PATH}" --template bad_template.XX 2> /dev/null
  status="$?"
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_num "${status}" 111; then
    failed_subtests=$((failed_subtests + 1))
  fi

  printf "Please exit without saving.\n" | "${NEOVIPE_PATH}" 1> /dev/null 2> /dev/null
  status="$?"
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_num "${status}" 1; then
    failed_subtests=$((failed_subtests + 1))
  fi

  printf "Please exit without saving.\n" | "${NEOVIPE_PATH}" --pipe-without-save 1> /dev/null 2> /dev/null
  status="$?"
  total_subtests=$((total_subtests + 1))
  if ! assert_eq_num "${status}" 0; then
    failed_subtests=$((failed_subtests + 1))
  fi

  if ! assert_eq_num "${failed_subtests}" 0; then
    printf "Failed %s subtests of %s.\n" "${failed_subtests}" "${total_subtests}" >&2
    return 1
  fi
}

runall() {
  total_tests=0
  failed_tests=0
  start_time=$(date +%s.%N)

  editing || {
    printf "FAILED: Editing Test\n" >&2
    failed_tests=$((failed_tests + 1))
  }
  exit_status || {
    printf "FAILED: Exit Status Test\n" >&2
    failed_tests=$((failed_tests + 1))
  }
  printf "Do you want to run the Saturation test? (y/N): "
  read -r response
  case "${response}" in
    [yY][eE][sS] | [yY])
      saturation || {
        printf "FAILED: Saturation Test\n" >&2
        failed_tests=$((failed_tests + 1))
      }
      cleanup && trap - EXIT HUP INT QUIT ABRT TERM
      ;;
    *) ;;
  esac

  runtime=$(printf "%s - %s\n" "$(date +%s.%N)" "${start_time}" | bc)
  printf "Ran %s tests in %s seconds.\n" "${total_tests}" "${runtime}"
  if assert_eq_num "${failed_tests}" 0; then
    printf "PASSED Test Suite\n"
    return 0
  else
    printf "Failed %s tests of %s.\n" "${failed_tests}" "${total_tests}" >&2
    return 1
  fi
}

runall
