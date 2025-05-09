"""
Main script for testing the development environment.
Run: python main.py
"""

import platform
import geopandas as gpd

try:
    import torch
    TORCH_AVAILABLE = True
except ImportError:
    TORCH_AVAILABLE = False

def get_runtime_info():
    info = {
        "python_version": platform.python_version(),
        "geopandas_version": gpd.__version__,
        "device": "CPU"
    }
    
    if TORCH_AVAILABLE:
        if torch.cuda.is_available():
            info["device"] = "GPU"
            info["gpu_name"] = torch.cuda.get_device_name(0)
            info["cuda_version"] = torch.version.cuda
        else:
            info["device"] = "CPU (Torch available, but no CUDA)"
    else:
        info["device"] = "CPU (Torch not installed)"

    return info

    return info

if __name__ == "__main__":
    print("Environment Check Passed:")
    for k, v in get_runtime_info().items():
        print(f"  {k}: {v}")
