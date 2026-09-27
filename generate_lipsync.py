from pathlib import Path
import subprocess


def generate_lipsync(
    video_path: Path,
    audio_path: Path,
    output_path: Path,
    inference_steps: int = 20,
    guidance_scale: float = 1.5,
    enable_deepcache: bool = True,
) -> Path:
    latentsync_dir = Path(__file__).parent

    video_path = video_path.resolve()
    audio_path = audio_path.resolve()
    output_path = output_path.resolve()
    latentsync_dir = latentsync_dir.resolve()

    config_path = latentsync_dir / "configs" / "unet" / "stage2_512.yaml"

    checkpoint_path = latentsync_dir / "checkpoints" / "latentsync_unet.pt"

    for path in [
        video_path,
        audio_path,
        config_path,
        checkpoint_path,
    ]:
        if not path.is_file():
            raise FileNotFoundError(f"File not found: {path}")

    output_path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    command = [
        "python",
        "-u",
        "-m",
        "scripts.inference",
        "--unet_config_path",
        str(config_path),
        "--inference_ckpt_path",
        str(checkpoint_path),
        "--inference_steps",
        str(inference_steps),
        "--guidance_scale",
        str(guidance_scale),
        "--video_path",
        str(video_path),
        "--audio_path",
        str(audio_path),
        "--video_out_path",
        str(output_path),
    ]

    if enable_deepcache:
        command.append("--enable_deepcache")

    subprocess.run(
        command,
        cwd=latentsync_dir,
        check=True,
    )

    if not output_path.is_file():
        raise RuntimeError(
            f"LatentSync did not generate the expected output: {output_path}"
        )

    return output_path
