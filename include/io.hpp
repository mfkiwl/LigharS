#include <fstream>

namespace gpumagi {

void snapshot_framebuf_bmp(
  const uint32_t* hostmem,
  uint32_t w,
  uint32_t h,
  const char* path
) {
  std::fstream f(path, std::ios::out | std::ios::binary | std::ios::trunc);
  f.write("BM", 2);
  uint32_t img_size = w * h * sizeof(uint32_t);
  uint32_t bmfile_hdr[] = { 14 + 108 + img_size, 0, 14 + 108 };
  f.write((const char*)bmfile_hdr, sizeof(bmfile_hdr));
  uint32_t bmcore_hdr[] = {
    108, w, h, 1 | (32 << 16), 3, img_size, 2835, 2835, 0, 0,
    0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000, 0x57696E20,
    0,0,0,0,0,0,0,0,0,0,0,0,
  };
  f.write((const char*)bmcore_hdr, sizeof(bmcore_hdr));
  uint8_t buf;
  for (auto i = 0; i < h; ++i) {
    for (auto j = 0; j < w; ++j) {
      for (auto k = 0; k < 4; ++k) {
        buf = hostmem[(h - i - 1) * w + j];
        f.write((const char*)&buf, sizeof(buf));
      }
    }
  }
  f.flush();
  f.close();
}

} // namespace gpumagi
