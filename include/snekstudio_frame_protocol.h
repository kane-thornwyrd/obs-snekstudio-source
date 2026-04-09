#pragma once

#include <stdint.h>

#define SNEKSTUDIO_FRAME_PROTOCOL_VERSION 1u
#define SNEKSTUDIO_FRAME_MAGIC "SNEKFB1"

enum snekstudio_pixel_format {
	SNEKSTUDIO_PIXEL_FORMAT_INVALID = 0,
	SNEKSTUDIO_PIXEL_FORMAT_BGRA8 = 1,
};

struct snekstudio_frame_header {
	char magic[8];
	uint32_t version;
	uint32_t header_size;
	uint32_t width;
	uint32_t height;
	uint32_t stride_bytes;
	uint32_t pixel_format;
	uint32_t data_offset;
	uint32_t data_size;
	uint64_t write_sequence;
	uint64_t frame_sequence;
	uint64_t timestamp_ns;
	uint32_t flags;
	uint32_t reserved0;
	uint8_t reserved[56];
};

enum snekstudio_frame_flags {
	SNEKSTUDIO_FRAME_FLAG_READY = 1u << 0,
};

_Static_assert(sizeof(struct snekstudio_frame_header) == 128, "Protocol header size must stay stable");