cmake_minimum_required(VERSION 4.0.2)

include(FetchContent)

FetchContent_Populate(
  mod_target
  URL ${MOD_BASE_FILES_URL}
  URL_HASH SHA256=${MOD_BASE_FILES_URL_HASH}
  SOURCE_DIR ${MOD_BASE_FILES_PATH}
  BINARY_DIR ${CMAKE_BINARY_DIR}
)
