# Profile: C++ / Dear ImGui

## Core Principles

- **Immediate mode GUI.** No persistent widget state — UI is rebuilt every frame.
  All UI logic lives inside the `ImGui::Begin()`/`ImGui::End()` block.
- **Frame loop is the heartbeat.** Everything renders per-frame. Keep frame
  callback lightweight (< 16ms for 60fps).
- **ImGui context is NOT thread-safe.** All ImGui calls must happen on the
  render thread.

## ImGui Patterns

**Prefer:**
```cpp
// Stateless UI — re-evaluate every frame
if (ImGui::Button("Run")) {
    doWork();
}
ImGui::SameLine();
if (ImGui::Checkbox("Enable", &enabled)) {
    applySettings();
}

// Use ##id for unique widget IDs when labels collide
ImGui::InputText("##input1", buf1, sizeof(buf1));
ImGui::InputText("##input2", buf2, sizeof(buf2));
```

**Avoid:**
```cpp
// Don't cache ImGui widget state manually
bool wasClicked = false;  // unnecessary — ImGui::Button returns this

// Don't call ImGui from worker threads
std::thread([](){ ImGui::Text("crash"); });  // NEVER
```

## Window Management

- Use `ImGui::SetNextWindowSize()` with `ImGuiCond_FirstUseEver` for initial layout.
- Docking: if using docking branch, enable via `io.ConfigFlags |= ImGuiConfigFlags_DockingEnable`.
- Viewports: `ImGuiConfigFlags_ViewportsEnable` for multi-window support.

## Backend Integration

| Backend | Typical Use |
|:---|:---|
| `imgui_impl_win32` + `imgui_impl_dx11` | Windows desktop (DirectX 11) |
| `imgui_impl_glfw` + `imgui_impl_opengl3` | Cross-platform (OpenGL) |
| `imgui_impl_sdl2` + `imgui_impl_vulkan` | SDL2 + Vulkan |

- Backend files live in `imgui/backends/`. Include only the pair you need.
- Initialize in order: platform backend first, then renderer backend.
- Shutdown in reverse order.

## Memory & Lifecycle

- ImGui manages its own memory pool internally. Don't `new`/`delete` ImGui objects.
- `ImGui::CreateContext()` / `ImGui::DestroyContext()` — one per application.
- Textures loaded via backend (e.g. `D3D11_CreateTexture`) must be released manually.
- Font atlas is built once at init. Adding fonts after init requires atlas rebuild.

## Threading Rules

- **All ImGui calls on render thread only.**
- Worker threads communicate results via shared state protected by `std::mutex`.
- Pattern: worker writes to shared buffer → render thread reads and displays.

```cpp
// Shared state
std::mutex mtx;
std::string statusMsg;

// Worker thread
{
    std::lock_guard<std::mutex> lock(mtx);
    statusMsg = "Processing complete";
}

// Render thread (inside frame loop)
{
    std::lock_guard<std::mutex> lock(mtx);
    ImGui::Text("%s", statusMsg.c_str());
}
```

## Performance

- Minimize draw calls: batch similar widgets together.
- Use `ImGui::BeginChild()` with scrolling for large lists instead of
  rendering all items.
- Use `ImGuiListClipper` for virtual scrolling on 1000+ item lists.
- Avoid loading large textures every frame — cache `ImTextureID`.

## Build Notes

- Include: `imgui.h`, `imgui_impl_<platform>.h`, `imgui_impl_<renderer>.h`
- Source: `imgui.cpp`, `imgui_draw.cpp`, `imgui_tables.cpp`, `imgui_widgets.cpp`
  + backend sources
- ImGui is typically compiled directly into the project (no separate lib/dll).
- Define `IMGUI_IMPL_WIN32_DISABLE_GAMEPAD` if gamepad input not needed.
