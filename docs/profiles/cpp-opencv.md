# Profile: C++ / OpenCV Vision Processing

## Core Principles

- **Edge-based matching over pixel-based.** Pixel SAD rotation is fragile;
  use Chamfer/gradient-based approaches with pre-computed rotation caches.
- **Learn phase separates from Match phase.** Pre-compute expensive operations
  (rotation, edge extraction, pyramids) during Learn; keep Match lightweight.
- **Distance transform for scoring.** Pre-compute `cv::distanceTransform` on
  scene edges once; slide template edge points over it.

## Memory Rules

- `cv::Mat` is ref-counted. Use `.clone()` for independent copies.
- Release large `Mat` objects explicitly when no longer needed (`mat.release()`).
- Pre-allocate buffers for hot-path processing — avoid per-frame allocation.
- For repeated operations (10,000+ cycles), verify zero memory growth.

## OpenCV Patterns

**Prefer:**
```cpp
cv::Mat gray;
cv::cvtColor(src, gray, cv::COLOR_BGR2GRAY);  // in-place safe
cv::Mat edges;
cv::Canny(gray, edges, threshold1, threshold2);
```

**Avoid:**
```cpp
cv::Mat* img = new cv::Mat();  // never heap-allocate Mat
```

## Threading with OpenCV

- OpenCV functions are generally **not thread-safe** for the same Mat.
- Each thread must work on its own Mat copy (`.clone()`).
- Use `cv::parallel_for_` or OpenMP for parallel processing.
- Protect shared state (template cache, results) with mutex.

## Performance Targets

| Operation | Target | Measurement |
|:---|:---|:---|
| Image acquisition | < 50ms | Camera capture + transfer |
| Vision processing | < 200ms | Full inspection cycle |
| Memory growth | < 1% over 1hr | Repeated match test |

## Validation Requirements

- **Memory leak test**: 10,000 repeated match cycles, memory delta < 2MB.
- **Multi-thread test**: 10 threads × 100 iterations, no crashes.
- **Long-running test**: 1hr continuous operation, memory growth < 1%.
- **Address Sanitizer**: zero reports on full test suite.

## Build Notes

- Link against: `opencv_core`, `opencv_imgproc`, `opencv_highgui` (+ others as needed)
- Include path: `[opencv-root]/include/opencv4`
- Lib path: `[opencv-root]/lib`
- Runtime DLLs must be in output directory or PATH.
