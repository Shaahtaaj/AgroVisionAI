"""Investigative preprocessing modes for Python/Flutter parity work."""

from __future__ import annotations

from pathlib import Path
from typing import Any


PREPROCESSING_MODES = (
    "flutter_default",
    "minus_one_to_one",
    "raw_0_to_255",
    "center_crop_0_to_1",
    "pillow_bilinear_0_to_1",
    "pillow_nearest_0_to_1",
    "pillow_bicubic_0_to_1",
    "tensorflow_resize_bilinear_0_to_1",
    "flutter_image_linear_candidate",
)

CANDIDATE_MODES = (
    "flutter_default",
    "pillow_bilinear_0_to_1",
    "pillow_nearest_0_to_1",
    "pillow_bicubic_0_to_1",
    "tensorflow_resize_bilinear_0_to_1",
    "flutter_image_linear_candidate",
)


def _flutter_image_linear(source: Any, np: Any) -> Any:
    """Approximate package:image 4.9.1 copyResize Interpolation.linear."""
    source = np.asarray(source, dtype=np.float64)
    source_height, source_width, _ = source.shape
    target_size = 224
    x = np.arange(target_size, dtype=np.float64) * (
        source_width / target_size
    )
    y = np.arange(target_size, dtype=np.float64) * (
        source_height / target_size
    )
    ix = np.floor(x).astype(np.int64)
    iy = np.floor(y).astype(np.int64)
    nx = np.minimum(ix + 1, source_width - 1)
    ny = np.minimum(iy + 1, source_height - 1)
    kx = (x - ix)[None, :, None]
    ky = (y - iy)[:, None, None]

    icc = source[iy[:, None], ix[None, :]]
    inc = source[iy[:, None], nx[None, :]]
    icn = source[ny[:, None], ix[None, :]]
    inn = source[ny[:, None], nx[None, :]]
    interpolated = (
        icc
        + kx * (inc - icc + ky * (icc + inn - icn - inc))
        + ky * (icn - icc)
    )
    # ImageDataUint8.setPixelRgba stores positive channel values with toInt(),
    # which truncates toward zero before the app reads and normalizes them.
    return np.trunc(interpolated).astype(np.uint8)


def preprocess_image(
    image_path: Path,
    mode: str,
    *,
    np: Any,
    Image: Any,
    tf: Any | None = None,
) -> tuple[Any, dict[str, Any]]:
    with Image.open(image_path) as source:
        original_size = source.size
        image = source.convert("RGB")
        if mode == "center_crop_0_to_1":
            side = min(image.width, image.height)
            left = (image.width - side) // 2
            top = (image.height - side) // 2
            image = image.crop((left, top, left + side, top + side))

        if mode in {
            "flutter_default",
            "pillow_bilinear_0_to_1",
            "minus_one_to_one",
            "raw_0_to_255",
            "center_crop_0_to_1",
        }:
            resized = image.resize(
                (224, 224), resample=Image.Resampling.BILINEAR
            )
            values = np.asarray(resized, dtype=np.float32)
            implementation = "Pillow Image.Resampling.BILINEAR"
        elif mode == "pillow_nearest_0_to_1":
            resized = image.resize(
                (224, 224), resample=Image.Resampling.NEAREST
            )
            values = np.asarray(resized, dtype=np.float32)
            implementation = "Pillow Image.Resampling.NEAREST"
        elif mode == "pillow_bicubic_0_to_1":
            resized = image.resize(
                (224, 224), resample=Image.Resampling.BICUBIC
            )
            values = np.asarray(resized, dtype=np.float32)
            implementation = "Pillow Image.Resampling.BICUBIC"
        elif mode == "tensorflow_resize_bilinear_0_to_1":
            if tf is None:
                raise RuntimeError("TensorFlow dependency is unavailable.")
            source_values = np.asarray(image, dtype=np.float32)
            values = tf.image.resize(
                source_values,
                (224, 224),
                method="bilinear",
                antialias=False,
            ).numpy()
            implementation = "TensorFlow tf.image.resize bilinear"
        elif mode == "flutter_image_linear_candidate":
            values = _flutter_image_linear(
                np.asarray(image, dtype=np.uint8), np=np
            ).astype(np.float32)
            implementation = (
                "Python implementation of package:image 4.9.1 "
                "copyResize Interpolation.linear"
            )
        else:
            raise ValueError(f"Unsupported preprocessing mode: {mode}")

    if mode == "minus_one_to_one":
        values = (values / np.float32(127.5)) - np.float32(1.0)
    elif mode == "raw_0_to_255":
        pass
    else:
        values = values / np.float32(255.0)
    tensor = np.expand_dims(values, axis=0).astype(np.float32, copy=False)
    metadata = {
        "original_size": list(original_size),
        "mode_after_decode": "RGB",
        "resized_size": [224, 224],
        "implementation": implementation,
        "normalization": (
            "raw 0-to-255" if mode == "raw_0_to_255"
            else "pixel / 255.0" if mode != "minus_one_to_one"
            else "(pixel / 127.5) - 1.0"
        ),
    }
    return tensor, metadata
