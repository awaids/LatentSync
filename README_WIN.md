## Setup command
powershell -ExecutionPolicy Bypass -File .\setup_latentsync.ps1

# LatentSync Integration

This project uses [LatentSync](https://github.com/bytedance/LatentSync) as a git submodule and provides a small Python wrapper to generate a lip-synced video from an input video and audio file.

## Project Structure

```text
your-project/
├── third_party/
│   └── LatentSync/
├── assets/
│   ├── agent.mp4
│   └── narration.wav
├── outputs/
├── main.py
└── pyproject.toml
```

## Setup

Clone the repository with submodules:

```bash
git clone --recurse-submodules <your-repo-url>
```

If the repository was already cloned:

```bash
git submodule update --init --recursive
```

Setup the project:
```
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Make sure the required LatentSync checkpoints exist under:

```text
third_party/LatentSync/checkpoints/
```

For example:

```text
third_party/LatentSync/checkpoints/
├── latentsync_unet.pt
└── whisper/
    └── tiny.pt
```

## Generate a Lip-Synced Video

Use the `generate_lipsync()` helper:

```python
from pathlib import Path

from latentsync_runner import generate_lipsync


project_dir = Path(__file__).resolve().parent

output_video = generate_lipsync(
    video_path=project_dir / "assets" / "agent.mp4",
    audio_path=project_dir / "assets" / "narration.wav",
    output_path=project_dir / "outputs" / "property_lipsync.mp4",
)

print(f"Generated video: {output_video}")
```

## Optional Arguments

You can also control LatentSync inference:

```python
output_video = generate_lipsync(
    video_path=video_path,
    audio_path=audio_path,
    output_path=output_path,
    inference_steps=20,
    guidance_scale=1.5,
    enable_deepcache=True,
)
```