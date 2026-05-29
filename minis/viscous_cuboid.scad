// viscous_cuboid: a cuboid with an irregular wavy top surface,
// defined by a sum of sine waves each with amplitude, direction,
// frequency, and phase.
//
// size: [x, y] footprint in mm
// height: base height in mm (waves oscillate around this)
// waves: list of [amplitude, direction_deg, freq_cycles_per_mm, phase_deg]
// resolution: grid spacing in mm (smaller = smoother, default 1)

// Sum of sine waves at point (x, y).
// Each wave contributes: amplitude * sin(freq * 360 * projection + phase)
// where projection = x*cos(dir) + y*sin(dir).
function wave_sum(x, y, waves, i=0) =
    i >= len(waves) ? 0 :
    waves[i][0] * sin(
        waves[i][2] * 360 * (x * cos(waves[i][1]) + y * sin(waves[i][1]))
        + waves[i][3]
    ) + wave_sum(x, y, waves, i+1);

module viscous_cuboid(size, height, waves, resolution=1) {
    nx = ceil(size[0] / resolution);
    ny = ceil(size[1] / resolution);
    dx = size[0] / nx;
    dy = size[1] / ny;

    // vertex indices into top and bottom grids
    function ti(i, j) = i * (ny+1) + j;
    function bi(i, j) = (nx+1)*(ny+1) + i * (ny+1) + j;

    points = concat(
        [for (i = [0:nx]) for (j = [0:ny])
            [i*dx, j*dy, height + wave_sum(i*dx, j*dy, waves)]],
        [for (i = [0:nx]) for (j = [0:ny])
            [i*dx, j*dy, 0]]
    );

    // All faces wound CCW when viewed from outside (outward normals).
    faces = concat(
        // Top surface (normal ~+z)
        [for (i=[0:nx-1]) for (j=[0:ny-1]) each [
            [ti(i,j), ti(i+1,j), ti(i,j+1)],
            [ti(i+1,j), ti(i+1,j+1), ti(i,j+1)]
        ]],
        // Bottom surface (normal -z)
        [for (i=[0:nx-1]) for (j=[0:ny-1]) each [
            [bi(i,j), bi(i,j+1), bi(i+1,j)],
            [bi(i,j+1), bi(i+1,j+1), bi(i+1,j)]
        ]],
        // Side x=0 (normal -x)
        [for (j=[0:ny-1]) each [
            [ti(0,j), ti(0,j+1), bi(0,j)],
            [ti(0,j+1), bi(0,j+1), bi(0,j)]
        ]],
        // Side x=max (normal +x)
        [for (j=[0:ny-1]) each [
            [ti(nx,j), bi(nx,j), ti(nx,j+1)],
            [bi(nx,j), bi(nx,j+1), ti(nx,j+1)]
        ]],
        // Side y=0 (normal -y)
        [for (i=[0:nx-1]) each [
            [ti(i,0), bi(i,0), ti(i+1,0)],
            [bi(i,0), bi(i+1,0), ti(i+1,0)]
        ]],
        // Side y=max (normal +y)
        [for (i=[0:nx-1]) each [
            [ti(i,ny), ti(i+1,ny), bi(i,ny)],
            [ti(i+1,ny), bi(i+1,ny), bi(i,ny)]
        ]]
    );

    polyhedron(points=points, faces=faces, convexity=10);
}

// --- Test examples ---

// Gentle blob: low-frequency waves, like a thick pudding
test_gentle = [
    // [amplitude, direction, freq (cycles/mm), phase]
    [1.5,   0, 0.04,   0],   // slow roll along x
    [1.0,  90, 0.05,  45],   // slow roll along y
    [0.7,  45, 0.07, 120],   // diagonal undulation
];

// Choppy surface: more waves, higher frequencies
test_choppy = [
    [1.2,   0, 0.06,   0],
    [1.0,  72, 0.08,  30],
    [0.8, 144, 0.10,  90],
    [0.6, 216, 0.12, 160],
    [0.4, 288, 0.15, 250],
];

// Sedated jelly: mostly calm with one dominant slow wave
test_sedated = [
    [2.0,  20, 0.03,   0],   // one big lazy wave
    [0.5, 110, 0.08,  60],   // faint cross-ripple
    [0.3, 160, 0.12, 200],   // subtle texture
];

// Uncomment one to preview:
//viscous_cuboid([50, 50], 8, test_gentle);
//viscous_cuboid([50, 50], 8, test_choppy);
//viscous_cuboid([50, 50], 8, test_sedated, resolution=0.5);
