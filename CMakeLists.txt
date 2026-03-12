cmake_minimum_required(VERSION 3.20)
project(EPLPredictorPro LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable Qt MOC/UIC/RCC by default (we will still disable for non-Qt targets)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

option(BUILD_GUI "Build Qt GUI application" ON)

# -------------------------
# Core library (NO Qt headers here)
# -------------------------
add_library(epl_core
    src/core/csv/CsvReader.cpp
    src/core/csv/CsvWriter.cpp
    src/core/domain/Types.cpp
    src/core/util/Random.cpp
    src/core/dataset/DatasetBuilder.cpp
    src/core/features/Normalizer.cpp
    src/core/ml/SoftmaxRegression.cpp
    src/core/ml/Metrics.cpp
    src/core/ml/ModelIO.cpp
    src/core/ml/Predictor.cpp
    src/core/ml/TeamRatingsDB.cpp
    src/core/stats/FormEngine.cpp
)

target_include_directories(epl_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# IMPORTANT: core must not run Qt MOC
set_target_properties(epl_core PROPERTIES
  AUTOMOC OFF
  AUTOUIC OFF
  AUTORCC OFF
)

if (MSVC)
  target_compile_options(epl_core PRIVATE /W4)
else()
  target_compile_options(epl_core PRIVATE -Wall -Wextra -Wpedantic)
endif()

# -------------------------
# CLI: build_dataset (CLI only)
# -------------------------
add_executable(build_dataset
    src/cli/build_dataset_main.cpp
)
target_link_libraries(build_dataset PRIVATE epl_core)

set_target_properties(build_dataset PROPERTIES
  AUTOMOC OFF
  AUTOUIC OFF
  AUTORCC OFF
)

# -------------------------
# CLI: train_model (CLI only)
# -------------------------
add_executable(train_model
    src/cli/train_main.cpp
)
target_link_libraries(train_model PRIVATE epl_core)

set_target_properties(train_model PROPERTIES
  AUTOMOC OFF
  AUTOUIC OFF
  AUTORCC OFF
)

# -------------------------
# GUI (Qt)
# -------------------------
if (BUILD_GUI)
  find_package(Qt6 COMPONENTS Widgets REQUIRED)

  add_executable(epl_app
      src/app/main.cpp
      src/app/MainWindow.h
      src/app/MainWindow.cpp

      src/app/pages/PredictorPage.h
      src/app/pages/PredictorPage.cpp

      src/app/widgets/ProbabilityBar.h
      src/app/widgets/ProbabilityBar.cpp
  )

  # Ensure MOC runs for GUI target
  set_target_properties(epl_app PROPERTIES
    AUTOMOC ON
    AUTOUIC ON
    AUTORCC ON
  )

  target_link_libraries(epl_app PRIVATE epl_core Qt6::Widgets)

  if (MSVC)
    target_compile_options(epl_app PRIVATE /W4)
  else()
    target_compile_options(epl_app PRIVATE -Wall -Wextra -Wpedantic)
  endif()
endif()