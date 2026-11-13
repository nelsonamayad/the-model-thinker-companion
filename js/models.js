// Shared helpers for every model page.
// Import from a model page with:
//   import {rng, rk4, player, C} from "../js/models.js"
// Everything random is deterministic given a seed, so a page's "Random seed"
// slider reproduces the same draws. The RNG and statistics are adapted from
// the sibling project's js/stats.js (gelman-lexicon, MIT).

// ---------- Chart palette ----------
// Each color passes 3:1 contrast on the light (#fbfaf6) and dark (#13161b)
// page backgrounds. Use currentColor for reference lines and text.
export const C = {
  teal: "#148a91",
  orange: "#d95f02",
  purple: "#7570b3",
  gray: "#8a8a8a",
  gold: "#b8860b",
  green: "#1a9850",
  red: "#d6604d",
  blue: "#3b75af"
};

// ---------- Random number generation ----------

// Seeded uniform generator (mulberry32) with distribution helpers attached.
export function rng(seed = 1) {
  let a = (seed * 2654435761) >>> 0;
  const u = () => {
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  let spare = null;
  u.uniform = (lo = 0, hi = 1) => lo + (hi - lo) * u();
  u.int = (lo, hi) => lo + Math.floor(u() * (hi - lo + 1));
  u.normal = (mu = 0, sd = 1) => {
    if (spare !== null) {
      const z = spare;
      spare = null;
      return mu + sd * z;
    }
    let x, y, s;
    do {
      x = 2 * u() - 1;
      y = 2 * u() - 1;
      s = x * x + y * y;
    } while (s >= 1 || s === 0);
    const m = Math.sqrt((-2 * Math.log(s)) / s);
    spare = y * m;
    return mu + sd * x * m;
  };
  u.normals = (n, mu = 0, sd = 1) => Array.from({ length: n }, () => u.normal(mu, sd));
  u.bernoulli = (p) => (u() < p ? 1 : 0);
  u.binomial = (n, p) => {
    let k = 0;
    for (let i = 0; i < n; i++) if (u() < p) k++;
    return k;
  };
  u.exponential = (rate = 1) => -Math.log(1 - u()) / rate;
  // Pareto (power law) with density proportional to x^(-alpha) on [xmin, inf).
  u.pareto = (alpha, xmin = 1) => xmin * Math.pow(1 - u(), -1 / (alpha - 1));
  u.lognormal = (mu = 0, sd = 1) => Math.exp(u.normal(mu, sd));
  u.gamma = (shape, scale = 1) => {
    if (shape < 1) return u.gamma(shape + 1, scale) * Math.pow(u(), 1 / shape);
    const d = shape - 1 / 3, c = 1 / Math.sqrt(9 * d);
    for (;;) {
      let x, v;
      do {
        x = u.normal();
        v = 1 + c * x;
      } while (v <= 0);
      v = v * v * v;
      const w = u();
      if (w < 1 - 0.0331 * x ** 4 || Math.log(w) < 0.5 * x * x + d * (1 - v + Math.log(v)))
        return d * v * scale;
    }
  };
  u.beta = (a, b) => {
    const x = u.gamma(a), y = u.gamma(b);
    return x / (x + y);
  };
  u.pick = (arr) => arr[Math.floor(u() * arr.length)];
  // Index drawn with probability proportional to the (non-negative) weights.
  u.weighted = (w) => {
    let total = 0;
    for (const v of w) total += v;
    let x = u() * total;
    for (let i = 0; i < w.length; i++) {
      x -= w[i];
      if (x < 0) return i;
    }
    return w.length - 1;
  };
  u.shuffle = (arr) => {
    const a2 = arr.slice();
    for (let i = a2.length - 1; i > 0; i--) {
      const j = Math.floor(u() * (i + 1));
      [a2[i], a2[j]] = [a2[j], a2[i]];
    }
    return a2;
  };
  return u;
}

// ---------- Sequences and summaries ----------

export const range = (n) => Array.from({ length: n }, (_, i) => i);
export const seq = (lo, hi, n) =>
  Array.from({ length: n }, (_, i) => lo + ((hi - lo) * i) / (n - 1));
export const sum = (x) => x.reduce((s, v) => s + v, 0);
export const mean = (x) => sum(x) / x.length;
export const variance = (x) => {
  const m = mean(x);
  return sum(x.map((v) => (v - m) ** 2)) / (x.length - 1);
};
export const sd = (x) => Math.sqrt(variance(x));
export const quantile = (x, p) => {
  const s = x.slice().sort((a, b) => a - b);
  const h = (s.length - 1) * p, lo = Math.floor(h), hi = Math.ceil(h);
  return s[lo] + (s[hi] - s[lo]) * (h - lo);
};
export const median = (x) => quantile(x, 0.5);
export const cor = (x, y) => {
  const mx = mean(x), my = mean(y);
  let sxy = 0, sxx = 0, syy = 0;
  for (let i = 0; i < x.length; i++) {
    sxy += (x[i] - mx) * (y[i] - my);
    sxx += (x[i] - mx) ** 2;
    syy += (y[i] - my) ** 2;
  }
  return sxy / Math.sqrt(sxx * syy);
};
export const clamp = (v, lo, hi) => Math.min(hi, Math.max(lo, v));
export const argmax = (x) => x.reduce((b, v, i) => (v > x[b] ? i : b), 0);

// Format a number with d decimals. Never prints "-0.00", and shows "–" when
// the value is undefined (NaN or infinite).
export const fmt = (v, d = 2) => {
  if (!Number.isFinite(v)) return "–";
  const s = v.toFixed(d);
  return /^-0\.?0*$/.test(s) ? s.slice(1) : s;
};
// Thousands separators: num(1234567) is "1,234,567".
export const num = (v, d = 0) =>
  Number.isFinite(v) ? v.toLocaleString("en-US", { maximumFractionDigits: d, minimumFractionDigits: d }) : "–";
export const pct = (v, d = 0) => (Number.isFinite(v) ? (100 * v).toFixed(d) + "%" : "–");

// ---------- Distributions ----------

export const dnorm = (x, mu = 0, s = 1) =>
  Math.exp(-0.5 * ((x - mu) / s) ** 2) / (s * Math.sqrt(2 * Math.PI));

// Standard normal CDF (Abramowitz-Stegun 7.1.26 via erf).
export function pnorm(z) {
  const t = 1 / (1 + 0.3275911 * Math.abs(z) / Math.SQRT2);
  const y =
    1 -
    (((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t) *
      Math.exp(-(z * z) / 2);
  return z >= 0 ? 0.5 * (1 + y) : 0.5 * (1 - y);
}

// Standard normal quantile (Acklam's approximation).
export function qnorm(p) {
  const a = [-39.6968302866538, 220.946098424521, -275.928510446969, 138.357751867269, -30.6647980661472, 2.50662827745924];
  const b = [-54.4760987982241, 161.585836858041, -155.698979859887, 66.8013118877197, -13.2806815528857];
  const c = [-0.00778489400243029, -0.322396458041136, -2.40075827716184, -2.54973253934373, 4.37466414146497, 2.93816398269878];
  const d = [0.00778469570904146, 0.32246712907004, 2.445134137143, 3.75440866190742];
  const pl = 0.02425;
  if (p < pl) {
    const q = Math.sqrt(-2 * Math.log(p));
    return (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
      ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
  }
  if (p > 1 - pl) return -qnorm(1 - p);
  const q = p - 0.5, r = q * q;
  return ((((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) * q) /
    (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1);
}

// Log gamma (Lanczos approximation, g = 7).
export function lgamma(x) {
  const c = [0.99999999999980993, 676.5203681218851, -1259.1392167224028, 771.32342877765313,
    -176.61502916214059, 12.507343278686905, -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7];
  if (x < 0.5) return Math.log(Math.PI / Math.abs(Math.sin(Math.PI * x))) - lgamma(1 - x);
  x -= 1;
  let a = c[0];
  const t = x + 7.5;
  for (let i = 1; i < 9; i++) a += c[i] / (x + i);
  return 0.5 * Math.log(2 * Math.PI) + (x + 0.5) * Math.log(t) - t + Math.log(a);
}

export const lchoose = (n, k) => lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1);

// Binomial probability of exactly k successes in n trials.
export function dbinom(k, n, p) {
  if (k < 0 || k > n) return 0;
  if (p === 0) return k === 0 ? 1 : 0;
  if (p === 1) return k === n ? 1 : 0;
  return Math.exp(lchoose(n, k) + k * Math.log(p) + (n - k) * Math.log(1 - p));
}

// Regularized incomplete beta I_x(a, b), by continued fraction.
function ibeta(x, a, b) {
  if (x <= 0) return 0;
  if (x >= 1) return 1;
  if (x > (a + 1) / (a + b + 2)) return 1 - ibeta(1 - x, b, a);
  const front = Math.exp(lgamma(a + b) - lgamma(a) - lgamma(b) + a * Math.log(x) + b * Math.log(1 - x));
  let f, c = 1, d = 1 - (a + b) * x / (a + 1);
  d = Math.abs(d) < 1e-300 ? 1e300 : 1 / d;
  f = d;
  for (let m = 1; m <= 300; m++) {
    for (const nm of [m * (b - m) * x / ((a + 2 * m - 1) * (a + 2 * m)), -(a + m) * (a + b + m) * x / ((a + 2 * m) * (a + 2 * m + 1))]) {
      d = 1 + nm * d; d = Math.abs(d) < 1e-300 ? 1e300 : 1 / d;
      c = 1 + nm / c; if (Math.abs(c) < 1e-300) c = 1e-300;
      f *= d * c;
    }
    if (Math.abs(d * c - 1) < 1e-12) break;
  }
  return front * f / a;
}

// Student t CDF with df degrees of freedom.
export function pt(t, df) {
  const tail = 0.5 * ibeta(df / (df + t * t), df / 2, 0.5);
  return t >= 0 ? 1 - tail : tail;
}

// Two-sided p-value of est / se against a t distribution with df degrees of
// freedom (or the normal when df is omitted).
export const pValue = (est, se, df) =>
  df ? 2 * (1 - pt(Math.abs(est / se), df)) : 2 * (1 - pnorm(Math.abs(est / se)));

// Shannon entropy of a probability vector, in bits by default. Zero
// probabilities contribute nothing.
export function entropy(p, base = 2) {
  let h = 0;
  for (const v of p) if (v > 0) h -= v * Math.log(v);
  return h / Math.log(base);
}

// ---------- Regression ----------

// Simple linear regression y = a + b x, with standard errors and R².
export function lm(x, y) {
  const n = x.length, mx = mean(x), my = mean(y);
  let sxy = 0, sxx = 0;
  for (let i = 0; i < n; i++) {
    sxy += (x[i] - mx) * (y[i] - my);
    sxx += (x[i] - mx) ** 2;
  }
  const b = sxy / sxx, a = my - b * mx;
  const resid = y.map((v, i) => v - a - b * x[i]);
  const sigma = Math.sqrt(sum(resid.map((r) => r * r)) / (n - 2));
  const seB = sigma / Math.sqrt(sxx);
  const seA = sigma * Math.sqrt(1 / n + mx ** 2 / sxx);
  const r2 = 1 - sum(resid.map((r) => r * r)) / sum(y.map((v) => (v - my) ** 2));
  return { a, b, seA, seB, sigma, r2, predict: (v) => a + b * v };
}

// Multiple regression by least squares. X is an array of rows (an intercept
// is added). Returns coefficients and standard errors, intercept first, and R².
export function ols(X, y) {
  const n = y.length, rows = X.map((r) => [1, ...r]), k = rows[0].length;
  const XtX = Array.from({ length: k }, () => new Array(k).fill(0));
  const Xty = new Array(k).fill(0);
  for (let i = 0; i < n; i++)
    for (let j = 0; j < k; j++) {
      Xty[j] += rows[i][j] * y[i];
      for (let l = 0; l < k; l++) XtX[j][l] += rows[i][j] * rows[i][l];
    }
  const inv = invert(XtX);
  const coef = inv.map((r) => sum(r.map((v, j) => v * Xty[j])));
  const fitted = rows.map((r) => sum(r.map((x, j) => x * coef[j])));
  const resid = y.map((v, i) => v - fitted[i]);
  const s2 = sum(resid.map((r) => r * r)) / (n - k);
  const my = mean(y);
  const r2 = 1 - sum(resid.map((r) => r * r)) / sum(y.map((v) => (v - my) ** 2));
  return { coef, se: inv.map((r, j) => Math.sqrt(s2 * r[j])), sigma: Math.sqrt(s2), r2, fitted, df: n - k };
}

export function invert(M) {
  const n = M.length, A = M.map((r, i) => [...r, ...M.map((_, j) => (i === j ? 1 : 0))]);
  for (let c = 0; c < n; c++) {
    let p = c;
    for (let r = c + 1; r < n; r++) if (Math.abs(A[r][c]) > Math.abs(A[p][c])) p = r;
    [A[c], A[p]] = [A[p], A[c]];
    const d = A[c][c];
    for (let j = 0; j < 2 * n; j++) A[c][j] /= d;
    for (let r = 0; r < n; r++)
      if (r !== c) {
        const f = A[r][c];
        for (let j = 0; j < 2 * n; j++) A[r][j] -= f * A[c][j];
      }
  }
  return A.map((r) => r.slice(n));
}

// ---------- Dynamics ----------

// Iterate a difference equation x_{t+1} = step(x_t, t) for T periods.
// Returns [x_0, x_1, ..., x_T]. States may be numbers, arrays or objects.
export function iterate(step, x0, T) {
  const out = [x0];
  let x = x0;
  for (let t = 0; t < T; t++) {
    x = step(x, t);
    out.push(x);
  }
  return out;
}

// Fourth-order Runge-Kutta for dy/dt = f(t, y), with y an array.
// Returns [{t, y}] every `every` steps of size dt from t0 to t1.
export function rk4(f, y0, { t0 = 0, t1 = 100, dt = 0.01, every = 10 } = {}) {
  let y = y0.slice(), t = t0;
  const out = [{ t, y: y.slice() }];
  const steps = Math.round((t1 - t0) / dt);
  const add = (a, k, h) => a.map((v, j) => v + h * k[j]);
  for (let i = 1; i <= steps; i++) {
    const k1 = f(t, y);
    const k2 = f(t + dt / 2, add(y, k1, dt / 2));
    const k3 = f(t + dt / 2, add(y, k2, dt / 2));
    const k4 = f(t + dt, add(y, k3, dt));
    y = y.map((v, j) => v + (dt / 6) * (k1[j] + 2 * k2[j] + 2 * k3[j] + k4[j]));
    t = t0 + i * dt;
    if (i % every === 0 || i === steps) out.push({ t, y: y.slice() });
  }
  return out;
}

// Row vector times matrix: the distribution after one Markov step.
export const vecMat = (x, P) => P[0].map((_, j) => x.reduce((s, xi, i) => s + xi * P[i][j], 0));

// Stationary distribution of a Markov transition matrix (rows sum to 1),
// by power iteration from the uniform distribution.
export function stationary(P, { iters = 100000, tol = 1e-13 } = {}) {
  let x = P.map(() => 1 / P.length);
  for (let k = 0; k < iters; k++) {
    const y = vecMat(x, P);
    if (y.reduce((s, v, i) => s + Math.abs(v - x[i]), 0) < tol) return y;
    x = y;
  }
  return x;
}

// ---------- Networks ----------
// A network is an adjacency list: adj[i] is the array of i's neighbours.

export function edgesOf(adj) {
  const e = [];
  adj.forEach((nb, i) => nb.forEach((j) => { if (i < j) e.push([i, j]); }));
  return e;
}

// Erdős–Rényi random network: each pair linked with probability p.
export function graphRandom(n, p, r) {
  const adj = Array.from({ length: n }, () => []);
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j < n; j++)
      if (r() < p) { adj[i].push(j); adj[j].push(i); }
  return adj;
}

// Watts–Strogatz small world: a ring where each node links to its k nearest
// neighbours (k even), then each edge is rewired with probability beta.
export function graphSmallWorld(n, k, beta, r) {
  const set = Array.from({ length: n }, () => new Set());
  for (let i = 0; i < n; i++)
    for (let j = 1; j <= k / 2; j++) {
      const t = (i + j) % n;
      set[i].add(t); set[t].add(i);
    }
  for (let j = 1; j <= k / 2; j++)
    for (let i = 0; i < n; i++) {
      const t = (i + j) % n;
      if (set[i].has(t) && r() < beta) {
        let v, tries = 0;
        do { v = Math.floor(r() * n); tries++; } while ((v === i || set[i].has(v)) && tries < 100);
        if (tries < 100) { set[i].delete(t); set[t].delete(i); set[i].add(v); set[v].add(i); }
      }
    }
  return set.map((s) => [...s]);
}

// Barabási–Albert preferential attachment: each new node links to m existing
// nodes chosen with probability proportional to their degree.
export function graphPrefAttach(n, m, r) {
  const adj = Array.from({ length: n }, () => []), ends = [];
  for (let i = 0; i <= m; i++)
    for (let j = i + 1; j <= m; j++) { adj[i].push(j); adj[j].push(i); ends.push(i, j); }
  for (let v = m + 1; v < n; v++) {
    const chosen = new Set();
    while (chosen.size < m) chosen.add(ends[Math.floor(r() * ends.length)]);
    for (const u of chosen) { adj[v].push(u); adj[u].push(v); ends.push(v, u); }
  }
  return adj;
}

// Hub and spoke: node 0 linked to every other node.
export const graphStar = (n) => Array.from({ length: n }, (_, i) => (i === 0 ? range(n).slice(1) : [0]));

// Breadth-first distances from s (-1 when unreachable).
export function bfs(adj, s) {
  const d = new Int32Array(adj.length).fill(-1);
  d[s] = 0;
  const q = [s];
  for (let h = 0; h < q.length; h++) {
    const v = q[h];
    for (const u of adj[v]) if (d[u] < 0) { d[u] = d[v] + 1; q.push(u); }
  }
  return d;
}

// Connected components: an array of component ids and the component sizes.
export function components(adj, alive = null) {
  const id = new Int32Array(adj.length).fill(-1), sizes = [];
  for (let s = 0; s < adj.length; s++) {
    if (id[s] >= 0 || (alive && !alive[s])) continue;
    const c = sizes.length, q = [s];
    id[s] = c;
    for (let h = 0; h < q.length; h++)
      for (const u of adj[q[h]]) if (id[u] < 0 && (!alive || alive[u])) { id[u] = c; q.push(u); }
    sizes.push(q.length);
  }
  return { id, sizes };
}

// Degree, clustering and path-length statistics. Path length is averaged
// over reachable pairs, from up to `sources` starting nodes.
export function graphStats(adj, { sources = 200 } = {}) {
  const n = adj.length, deg = adj.map((a) => a.length);
  let cl = 0, clN = 0;
  for (let i = 0; i < n; i++) {
    const nb = adj[i], k = nb.length;
    if (k < 2) continue;
    const s = new Set(nb);
    let links = 0;
    for (let a = 0; a < k; a++) for (const b of adj[nb[a]]) if (s.has(b)) links++;
    cl += links / (k * (k - 1));
    clN++;
  }
  let dist = 0, pairs = 0, diameter = 0;
  const step = Math.max(1, Math.floor(n / sources));
  for (let s = 0; s < n; s += step) {
    const d = bfs(adj, s);
    for (let t = 0; t < n; t++) if (t !== s && d[t] > 0) { dist += d[t]; pairs++; if (d[t] > diameter) diameter = d[t]; }
  }
  const comp = components(adj);
  return {
    n, edges: sum(deg) / 2, meanDegree: mean(deg), maxDegree: Math.max(...deg),
    clustering: clN ? cl / clN : 0, pathLength: pairs ? dist / pairs : NaN, diameter,
    largest: Math.max(...comp.sizes), degrees: deg
  };
}

// Force-directed layout (Fruchterman–Reingold) in the unit square, seeded
// so the same network always gets the same picture.
export function layoutForce(adj, r, { iterations = 250 } = {}) {
  const n = adj.length, k = Math.sqrt(1 / n);
  const x = range(n).map(() => r()), y = range(n).map(() => r());
  const edges = edgesOf(adj);
  let temp = 0.1;
  for (let it = 0; it < iterations; it++) {
    const dx = new Float64Array(n), dy = new Float64Array(n);
    for (let i = 0; i < n; i++)
      for (let j = i + 1; j < n; j++) {
        let ex = x[i] - x[j], ey = y[i] - y[j];
        const d2 = Math.max(1e-6, ex * ex + ey * ey), f = (k * k) / d2;
        dx[i] += ex * f; dy[i] += ey * f; dx[j] -= ex * f; dy[j] -= ey * f;
      }
    for (const [i, j] of edges) {
      const ex = x[i] - x[j], ey = y[i] - y[j], d = Math.sqrt(ex * ex + ey * ey) + 1e-9, f = d / k;
      dx[i] -= ex * f; dy[i] -= ey * f; dx[j] += ex * f; dy[j] += ey * f;
    }
    for (let i = 0; i < n; i++) {
      const d = Math.sqrt(dx[i] ** 2 + dy[i] ** 2) + 1e-9, s = Math.min(d, temp) / d;
      x[i] = clamp(x[i] + dx[i] * s, 0, 1);
      y[i] = clamp(y[i] + dy[i] * s, 0, 1);
    }
    temp *= 0.98;
  }
  return range(n).map((i) => ({ i, x: x[i], y: y[i] }));
}

// Nodes evenly spaced on a circle.
export const layoutCircle = (n) =>
  range(n).map((i) => ({ i, x: 0.5 + 0.5 * Math.cos((2 * Math.PI * i) / n - Math.PI / 2), y: 0.5 + 0.5 * Math.sin((2 * Math.PI * i) / n - Math.PI / 2) }));

// ---------- Grids (agent-based replays) ----------

// The eight neighbours (Moore neighbourhood) of every cell of an n-by-n torus:
// neighbours of cell c are nb[8c] ... nb[8c + 7].
export function torus8(n) {
  const nb = new Int32Array(n * n * 8);
  for (let y = 0; y < n; y++)
    for (let x = 0; x < n; x++) {
      let k = 0;
      for (let dy = -1; dy <= 1; dy++)
        for (let dx = -1; dx <= 1; dx++)
          if (dx || dy) nb[(y * n + x) * 8 + k++] = ((y + dy + n) % n) * n + ((x + dx + n) % n);
    }
  return nb;
}

// The four neighbours (von Neumann neighbourhood) of every cell, without
// wrapping at the edges (-1 where there is no neighbour).
export function grid4(n) {
  const nb = new Int32Array(n * n * 4).fill(-1);
  for (let y = 0; y < n; y++)
    for (let x = 0; x < n; x++) {
      const c = (y * n + x) * 4;
      if (y > 0) nb[c] = (y - 1) * n + x;
      if (y < n - 1) nb[c + 1] = (y + 1) * n + x;
      if (x > 0) nb[c + 2] = y * n + x - 1;
      if (x < n - 1) nb[c + 3] = y * n + x + 1;
    }
  return nb;
}

// Draw an n-by-n grid of states on a canvas: colors[state] is a CSS color,
// or null to leave the cell transparent (the page background shows through).
// The canvas carries role="img" and an aria-label, like every Plot chart.
export function drawGrid(cells, n, colors, { size = 420, ariaLabel = "Grid", ariaDescription = "" } = {}) {
  const px = Math.max(1, Math.floor(size / n));
  const canvas = document.createElement("canvas");
  canvas.width = canvas.height = px * n;
  canvas.className = "mt-grid";
  canvas.style.maxWidth = `${px * n}px`;
  canvas.setAttribute("role", "img");
  canvas.setAttribute("aria-label", ariaDescription ? `${ariaLabel}. ${ariaDescription}` : ariaLabel);
  const ctx = canvas.getContext("2d");
  for (let i = 0; i < cells.length; i++) {
    const col = colors[cells[i]];
    if (!col) continue;
    ctx.fillStyle = col;
    ctx.fillRect((i % n) * px, Math.floor(i / n) * px, px, px);
  }
  return canvas;
}

// ---------- Inputs ----------

// A play/pause button plus a step slider, for stepping through a run that
// has already been computed. Use as `viewof t = player(T, {label: "Week"})`.
// It starts paused at `value` (default: the last step); Play runs from the
// start. Animations never start on their own.
export function player(max, { value = max, label = "Step", delay = 120, step = 1 } = {}) {
  const form = document.createElement("form");
  form.className = "mt-player";
  const btn = document.createElement("button");
  btn.type = "button";
  btn.className = "mt-play";
  const lab = document.createElement("label");
  const span = document.createElement("span");
  span.textContent = label;
  const input = document.createElement("input");
  Object.assign(input, { type: "range", min: 0, max, step, value });
  input.setAttribute("aria-label", label);
  const out = document.createElement("output");
  lab.append(span, input, out);
  form.append(btn, lab);
  let timer = null;
  const show = (playing) => {
    btn.textContent = playing ? "❚❚ Pause" : "▶ Play";
    btn.setAttribute("aria-label", playing ? "Pause" : "Play");
  };
  const set = (v) => {
    form.value = v;
    input.value = v;
    out.value = v;
    form.dispatchEvent(new Event("input", { bubbles: true }));
  };
  const stop = () => {
    if (timer) clearInterval(timer);
    timer = null;
    show(false);
  };
  input.addEventListener("input", (e) => {
    e.stopPropagation();
    stop();
    set(+input.value);
  });
  btn.addEventListener("click", () => {
    if (timer) return stop();
    if (form.value >= max) set(0);
    show(true);
    timer = setInterval(() => {
      if (!form.isConnected || form.value >= max) return stop();
      set(Math.min(max, form.value + step));
    }, delay);
  });
  form.addEventListener("submit", (e) => e.preventDefault());
  form.value = value;
  out.value = value;
  show(false);
  return form;
}

// Wrap a control so the simulation recomputes only when the reader pauses,
// not on every step of a slider drag:
//   viewof n = debounce(Inputs.range([20, 400], {value: 100, label: "n"}))
export function debounce(input, wait = 250) {
  let timer = null, passing = false;
  input.addEventListener("input", (event) => {
    if (passing) return;
    event.stopImmediatePropagation();
    clearTimeout(timer);
    timer = setTimeout(() => {
      passing = true;
      input.dispatchEvent(new Event("input", { bubbles: true }));
      passing = false;
    }, wait);
  });
  return input;
}
