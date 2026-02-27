import tensorflow as tf


def main() -> None:
    print(f"TensorFlow: {tf.__version__}")
    print(f"Built with CUDA: {tf.test.is_built_with_cuda()}")
    gpus = tf.config.list_physical_devices("GPU")
    print(f"GPUs: {gpus}")

    if gpus:
        for gpu in gpus:
            try:
                tf.config.experimental.set_memory_growth(gpu, True)
            except Exception:
                pass
        print("GPU is available for TensorFlow.")
    else:
        print("No GPU detected by TensorFlow.")


if __name__ == "__main__":
    main()
