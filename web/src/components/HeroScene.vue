<template>
  <canvas ref="canvasEl" id="hero-canvas" />
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const canvasEl = ref(null)
let renderer, scene, camera, animId, clock
let riceStalks = [], particles, particlePositions, ground
let currentTheme = 'dark'

function readTheme() {
  currentTheme = document.documentElement.dataset.theme || 'dark'
  return currentTheme
}

function applySceneTheme() {
  if (!scene) return
  if (currentTheme === 'light') {
    scene.background = new THREE.Color(0xf5faf6)
    scene.fog = new THREE.FogExp2(0xf0f8f2, 0.030)
  } else {
    scene.background = new THREE.Color(0x061a0f)
    scene.fog = new THREE.FogExp2(0x081e12, 0.042)
  }
}

/* ── Geometry helpers ───────────────────────────────────────────── */
function buildRiceStalk(height = 1.8) {
  const group = new THREE.Group()
  const segments = 6
  const points = []
  for (let i = 0; i <= segments; i++) {
    const t = i / segments
    const bend = Math.sin(t * Math.PI * 0.5) * 0.35
    points.push(new THREE.Vector3(bend, t * height, 0))
  }
  const curve = new THREE.CatmullRomCurve3(points)
  const stalkGeo = new THREE.TubeGeometry(curve, 12, 0.012, 5, false)
  const stalkMat = new THREE.MeshStandardMaterial({
    color: new THREE.Color(0x3a7d44),
    roughness: 0.8,
    metalness: 0.0,
  })
  const stalk = new THREE.Mesh(stalkGeo, stalkMat)
  group.add(stalk)

  // Leaf
  const leafShape = new THREE.Shape()
  leafShape.moveTo(0, 0)
  leafShape.quadraticCurveTo(0.18, 0.25, 0, 0.6)
  leafShape.quadraticCurveTo(-0.18, 0.25, 0, 0)
  const leafGeo = new THREE.ShapeGeometry(leafShape, 8)
  const leafMat = new THREE.MeshStandardMaterial({
    color: new THREE.Color(0x4a9f57),
    side: THREE.DoubleSide,
    roughness: 0.7,
  })
  const leaf = new THREE.Mesh(leafGeo, leafMat)
  leaf.position.set(0.05, height * 0.55, 0)
  leaf.rotation.z = Math.PI / 8
  leaf.rotation.y = Math.random() * Math.PI
  group.add(leaf)

  // Grain head
  const grainGeo = new THREE.ConeGeometry(0.04, 0.28, 6)
  const grainMat = new THREE.MeshStandardMaterial({
    color: new THREE.Color(0xd4a843),
    roughness: 0.9,
  })
  const grain = new THREE.Mesh(grainGeo, grainMat)
  grain.position.set(0.35, height, 0)
  grain.rotation.z = Math.PI / 3
  group.add(grain)

  return group
}

function buildGround() {
  const geo = new THREE.PlaneGeometry(60, 60, 40, 40)
  // Terrain ripple
  const pos = geo.attributes.position
  for (let i = 0; i < pos.count; i++) {
    const x = pos.getX(i)
    const z = pos.getY(i)
    pos.setZ(i, Math.sin(x * 0.3) * 0.15 + Math.cos(z * 0.4) * 0.1)
  }
  geo.computeVertexNormals()
  const mat = new THREE.MeshStandardMaterial({
    color: new THREE.Color(0x1a4a2e),
    roughness: 1,
    metalness: 0,
  })
  const mesh = new THREE.Mesh(geo, mat)
  mesh.rotation.x = -Math.PI / 2
  mesh.position.y = -0.02
  return mesh
}

function buildParticles(count = 280) {
  const geo = new THREE.BufferGeometry()
  const positions = new Float32Array(count * 3)
  const colors = new Float32Array(count * 3)
  for (let i = 0; i < count; i++) {
    positions[i * 3]     = (Math.random() - 0.5) * 30
    positions[i * 3 + 1] = Math.random() * 8
    positions[i * 3 + 2] = (Math.random() - 0.5) * 30

    const bright = 0.4 + Math.random() * 0.6
    colors[i * 3]     = bright * 0.3
    colors[i * 3 + 1] = bright
    colors[i * 3 + 2] = bright * 0.3
  }
  geo.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  geo.setAttribute('color', new THREE.BufferAttribute(colors, 3))
  const mat = new THREE.PointsMaterial({
    size: 0.055,
    vertexColors: true,
    transparent: true,
    opacity: 0.65,
    sizeAttenuation: true,
  })
  return { points: new THREE.Points(geo, mat), positions }
}

/* ── Scene setup ────────────────────────────────────────────────── */
function initScene(canvas) {
  clock = new THREE.Clock()
  scene = new THREE.Scene()
  readTheme()
  applySceneTheme()

  renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false })
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  renderer.shadowMap.enabled = true
  renderer.shadowMap.type = THREE.PCFSoftShadowMap
  resize()

  camera = new THREE.PerspectiveCamera(55, canvas.clientWidth / canvas.clientHeight, 0.1, 120)
  camera.position.set(0, 3.5, 10)
  camera.lookAt(0, 1.5, 0)

  // Lights
  const ambient = new THREE.AmbientLight(0x1a3d28, currentTheme === 'light' ? 2.9 : 2.5)
  scene.add(ambient)

  const sun = new THREE.DirectionalLight(0xfff3c0, currentTheme === 'light' ? 4.8 : 4)
  sun.position.set(8, 18, 5)
  sun.castShadow = true
  sun.shadow.mapSize.width = 1024
  sun.shadow.mapSize.height = 1024
  sun.shadow.camera.near = 1
  sun.shadow.camera.far = 60
  sun.shadow.camera.left = -20
  sun.shadow.camera.right = 20
  sun.shadow.camera.top = 20
  sun.shadow.camera.bottom = -20
  scene.add(sun)

  const rimLight = new THREE.DirectionalLight(0x00ff88, 0.8)
  rimLight.position.set(-6, 4, -8)
  scene.add(rimLight)

  // Ground
  ground = buildGround()
  ground.receiveShadow = true
  scene.add(ground)

  // Stalks grid
  const rows = 14, cols = 14
  for (let r = 0; r < rows; r++) {
    for (let c = 0; c < cols; c++) {
      const stalk = buildRiceStalk(1.4 + Math.random() * 0.8)
      const x = (c - cols / 2) * 1.4 + (Math.random() - 0.5) * 0.5
      const z = (r - rows / 2) * 1.4 + (Math.random() - 0.5) * 0.5
      stalk.position.set(x, 0, z)
      stalk.rotation.y = Math.random() * Math.PI * 2
      stalk.userData = {
        baseX: x, baseZ: z,
        swayOffset: Math.random() * Math.PI * 2,
        swaySpeed: 0.6 + Math.random() * 0.5,
        swayAmp: 0.04 + Math.random() * 0.05,
      }
      stalk.castShadow = true
      riceStalks.push(stalk)
      scene.add(stalk)
    }
  }

  // Particles
  const p = buildParticles(320)
  particles = p.points
  particlePositions = p.positions
  scene.add(particles)
}

function onThemeChanged(event) {
  const nextTheme = event?.detail?.theme
  if (nextTheme === 'dark' || nextTheme === 'light') {
    currentTheme = nextTheme
  } else {
    currentTheme = readTheme()
  }
  applySceneTheme()
}

/* ── Animate ────────────────────────────────────────────────────── */
function animate() {
  animId = requestAnimationFrame(animate)
  const t = clock.getElapsedTime()

  // Sway stalks
  riceStalks.forEach((s) => {
    const d = s.userData
    const sway = Math.sin(t * d.swaySpeed + d.swayOffset) * d.swayAmp
    s.rotation.x = sway * 0.6
    s.rotation.z = sway
  })

  // Drift particles
  const pos = particles.geometry.attributes.position
  for (let i = 0; i < pos.count; i++) {
    pos.setY(i, pos.getY(i) + 0.004)
    if (pos.getY(i) > 8) pos.setY(i, 0)
    pos.setX(i, pos.getX(i) + Math.sin(t * 0.3 + i) * 0.001)
  }
  pos.needsUpdate = true

  // Gentle camera orbit
  const orbitR = 10
  camera.position.x = Math.sin(t * 0.07) * orbitR * 0.3
  camera.position.z = orbitR + Math.cos(t * 0.07) * orbitR * 0.15
  camera.lookAt(0, 1.8, 0)

  renderer.render(scene, camera)
}

/* ── Resize ─────────────────────────────────────────────────────── */
function resize() {
  const canvas = canvasEl.value
  if (!canvas) return
  const w = canvas.parentElement.clientWidth
  const h = canvas.parentElement.clientHeight
  renderer.setSize(w, h, false)
  if (camera) {
    camera.aspect = w / h
    camera.updateProjectionMatrix()
  }
}

onMounted(() => {
  initScene(canvasEl.value)
  animate()
  window.addEventListener('resize', resize)
  window.addEventListener('app-theme-change', onThemeChanged)
})

onUnmounted(() => {
  cancelAnimationFrame(animId)
  window.removeEventListener('resize', resize)
  window.removeEventListener('app-theme-change', onThemeChanged)
  renderer?.dispose()
})
</script>
