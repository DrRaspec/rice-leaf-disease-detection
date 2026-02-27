const DEFAULTS = {
  maxDimension: 1024,
  targetBytes: 900 * 1024,
  maxQuality: 0.86,
  minQuality: 0.6,
}

function toJpegName(originalName = 'upload') {
  const dot = originalName.lastIndexOf('.')
  const base = dot > 0 ? originalName.slice(0, dot) : originalName
  return `${base}.jpg`
}

function loadImage(file) {
  return new Promise((resolve, reject) => {
    const url = URL.createObjectURL(file)
    const image = new Image()
    image.onload = () => {
      URL.revokeObjectURL(url)
      resolve(image)
    }
    image.onerror = () => {
      URL.revokeObjectURL(url)
      reject(new Error('Unable to decode the selected image.'))
    }
    image.src = url
  })
}

function canvasToBlob(canvas, quality) {
  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => {
        if (!blob) {
          reject(new Error('Failed to encode optimized image.'))
          return
        }
        resolve(blob)
      },
      'image/jpeg',
      quality,
    )
  })
}

export async function optimizeImageForUpload(file, options = {}) {
  if (!file || !file.type?.startsWith('image/')) {
    throw new Error('Please select an image file.')
  }

  const config = { ...DEFAULTS, ...options }
  const image = await loadImage(file)
  const longestSide = Math.max(image.width, image.height)
  const scale = longestSide > config.maxDimension ? config.maxDimension / longestSide : 1
  const width = Math.max(1, Math.round(image.width * scale))
  const height = Math.max(1, Math.round(image.height * scale))

  const canvas = document.createElement('canvas')
  canvas.width = width
  canvas.height = height
  const ctx = canvas.getContext('2d')
  if (!ctx) {
    throw new Error('Image processing is not supported in this browser.')
  }
  ctx.drawImage(image, 0, 0, width, height)

  let quality = config.maxQuality
  let blob = await canvasToBlob(canvas, quality)
  while (blob.size > config.targetBytes && quality > config.minQuality) {
    quality = Math.max(config.minQuality, quality - 0.08)
    blob = await canvasToBlob(canvas, quality)
  }

  const likelyHeic = /heic|heif/i.test(file.type) || /\.hei[cf]$/i.test(file.name)
  const keepOriginal = !likelyHeic && blob.size >= file.size * 0.95 && file.size <= config.targetBytes
  if (keepOriginal) {
    return file
  }

  return new File([blob], toJpegName(file.name), {
    type: 'image/jpeg',
    lastModified: Date.now(),
  })
}
