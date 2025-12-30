cmake_minimum_required (VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Release>:Release>")
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

# Enable Hot Reload for MSVC compilers if supported.
if (POLICY CMP0141)
	cmake_policy(SET CMP0141 NEW)
	set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

set(PRODUCTION_BUILD OFF CACHE BOOL "Make this a production build" FORCE)
project (DualSenseY)
file(GLOB_RECURSE MY_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp")

if(WIN32)
	add_executable(${PROJECT_NAME} WIN32 ${MY_SOURCES} icon.rc)
	target_compile_definitions("${PROJECT_NAME}" PUBLIC WINDOWS=1 _CRT_SECURE_NO_WARNINGS=1)
elseif(APPLE)
	add_executable(${PROJECT_NAME} ${MY_SOURCES})
	target_compile_definitions("${PROJECT_NAME}" PUBLIC APPLE=1)
elseif(UNIX)
	add_executable(${PROJECT_NAME} ${MY_SOURCES})
	target_compile_definitions("${PROJECT_NAME}" PUBLIC LINUX=1)
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(${PROJECT_NAME} PUBLIC
	"${CMAKE_CURRENT_SOURCE_DIR}/include"
	"${CMAKE_CURRENT_SOURCE_DIR}/source"
)

if(PRODUCTION_BUILD)
	target_compile_definitions("${PROJECT_NAME}" PUBLIC RESOURCES_PATH="./resources/")
	target_compile_definitions("${PROJECT_NAME}" PUBLIC PRODUCTION_BUILD=1)
	target_compile_definitions("${PROJECT_NAME}" PUBLIC DEVELOPMENT_BUILD=0)
	add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/resources $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources)
else()
	target_compile_definitions("${PROJECT_NAME}" PUBLIC RESOURCES_PATH="${CMAKE_CURRENT_SOURCE_DIR}/resources/")
	target_compile_definitions("${PROJECT_NAME}" PUBLIC PRODUCTION_BUILD=0)
	target_compile_definitions("${PROJECT_NAME}" PUBLIC DEVELOPMENT_BUILD=1)
endif()

if(MSVC)
	target_compile_options(${PROJECT_NAME} PRIVATE /utf-8)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	target_compile_options(${PROJECT_NAME} PRIVATE -finput-charset=UTF-8 -fexec-charset=UTF-8)
endif()

# add dependencies
include(cmake/CPM.cmake)

include(cmake/asio.cmake)
CPMAddPackage(NAME GLFW
	GITHUB_REPOSITORY glfw/glfw
	GIT_TAG 3.4
	OPTIONS
		"GLFW_BUILD_TESTS OFF"
		"GLFW_BUILD_EXAMPLES OFF"
		"GLFW_BUILD_DOCS OFF"
)
CPMAddPackage("gh:nlohmann/json@3.12.0")
CPMAddPackage("gh:nefarius/ViGEmClient@1.21.222.0")
CPMAddPackage(NAME PlatformFolders
	GITHUB_REPOSITORY sago007/PlatformFolders
	GIT_TAG 4.3.0
)

add_subdirectory(thirdparty/glad)
add_subdirectory(thirdparty/imgui)
add_subdirectory(thirdparty/duaLib)
add_subdirectory(thirdparty/miniaudio)
add_subdirectory(thirdparty/stb_image)
add_subdirectory(thirdparty/nativefiledialog)
add_subdirectory(thirdparty/miniupnp/miniupnpc)
add_subdirectory(thirdparty/Updater)
add_subdirectory(thirdparty/traypp)

target_link_libraries(${PROJECT_NAME} PRIVATE
	glfw
	glad
	imgui
	duaLib
	nlohmann_json::nlohmann_json
	miniaudio
	ViGEmClient
	asio
	stb_image
	nativefiledialog
	sago::platform_folders
	libminiupnpc-static
	tiny-process-library
	tray
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:Updater> $<TARGET_FILE_DIR:${PROJECT_NAME}>)