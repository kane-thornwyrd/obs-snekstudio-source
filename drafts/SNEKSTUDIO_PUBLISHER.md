# SnekStudio Publisher Draft

This draft is the producer-side reference for integrating SnekStudio with the OBS plugin.

Files:

- `drafts/snekstudio_publisher_draft.h`
- `drafts/snekstudio_publisher_draft.c`

What it gives you:

- A tiny POSIX publisher that owns the shared frame file.
- A `begin_frame` and `end_frame` API for direct rendering into the mapped BGRA8 payload.
- A `publish_copy` API for simpler pipelines that already have a CPU-side frame buffer.

Suggested integration flow inside SnekStudio:

```c
struct snekstudio_publisher publisher;
struct snekstudio_publisher_frame frame;

if (!snekstudio_publisher_init(&publisher, path, width, height)) {
    fprintf(stderr, "%s\n", snekstudio_publisher_last_error(&publisher));
    return false;
}

if (snekstudio_publisher_begin_frame(&publisher, &frame)) {
    render_bgra_into(frame.pixels, frame.stride_bytes, frame.width, frame.height);
    snekstudio_publisher_end_frame(&publisher, current_time_ns());
}
```

Draft limitations:

- Linux and POSIX oriented.
- BGRA8 only.
- No internal locking.
- No automatic dirty-region tracking or dmabuf export.

That is intentional. The draft is meant to be easy to embed into SnekStudio first, then replace or optimize later if profiling justifies it.