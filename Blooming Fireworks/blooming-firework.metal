// https://uvolchyk.medium.com/blooming-fireworks-with-metal-and-swiftui-6550cef997e2

#import <metal_stdlib>
using namespace metal;

// Easing function for smooth transitions
float easeOutQuint(float t) {
  return 1.0 - pow(1.0 - t, 5.0);
}

// Simple noise function based on 2D coordinates
float noise(float2 co) {
  return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

// Inverse function for blending based on a range
float rangedInverse(float x, float minRange, float maxRange) {
  float inverse = 0.001 / x;
  float blendFactor = smoothstep(minRange, maxRange, x);
  return inverse * (1.0 - blendFactor);
}

// Quadratic Bezier curve calculation
float2 quadraticBezier(float2 p0, float2 p1, float2 p2, float t) {
    float u = 1.0 - t;
    float tt = t * t;
    float uu = u * u;
    float2 p = uu * p0;
    p += 2.0 * u * t * p1;
    p += tt * p2;
    return p;
}

// Function to calculate the trail effect
float trail(
  float2 uv,
  float t,
  float animationProgress,
  float animationDuration,
  float samplesCount,
  float2 startPoint,
  float2 endPoint
) {
  float intensity = 0.0;
  
  // Calculate progress of the head of the trail
  float headProgress = animationProgress / animationDuration;

  // Control point for the Bezier curve
  float2 controlPoint = float2(startPoint.x, startPoint.y - 0.2);
  float2 headPos = quadraticBezier(startPoint, controlPoint, endPoint, headProgress);

  // Distance from the current position to the head of the trail
  float headDist = distance(uv, headPos);
  if (headDist > 0.4) { return 0.0; }

  // Loop through samples to create the tail of the trail
  for(int i = 0; i < samplesCount * (1.0 - headProgress); i++) {
    float normalizedIndex = float(i) / float(samplesCount);

    float tailRelativeProgress = max(headProgress - normalizedIndex, 0.0);
    if (tailRelativeProgress == 0.0) { continue; }

    // Calculate the position of the tail point
    float2 tailPointPosition = quadraticBezier(startPoint, controlPoint, endPoint, tailRelativeProgress);

    float particlePos = tailRelativeProgress / headProgress;
    float fadeStart = smoothstep(0.9, 1.0, headProgress);
    float fade = smoothstep(fadeStart, 1.0, particlePos);

    // Add noise to the tail point for a more dynamic effect
    if (normalizedIndex > 0.8 - headProgress) {
      float noiseAmplitude = 0.01;
    
      float noiseValue = noise(float2(float(i) * 0.5 + t * 3.0, t * 2.0)) * 2.0 - 1.0;
      tailPointPosition.y += noiseValue * noiseAmplitude;
      tailPointPosition.x += noiseValue * (noiseAmplitude * 2.0);
    }

    // Calculate the glow intensity based on distance
    float dist = distance(uv, tailPointPosition);
    float coreGlow = exp(-dist * (100.0 + 200.0 * normalizedIndex * headProgress));
    float bloomGlow = rangedInverse(dist, 0.0, 0.4);

    intensity += (coreGlow + bloomGlow) * fade;
  }

  return intensity;
}

// Main function to apply the trail effect
[[ stitchable ]]
half4 trailEffect(
  float2 position,
  half4 color,
  float currentTime,
  float2 resolution,
  float2 endPoint,
  half4 burstColor
) {
  float2 uv = (position - 0.5 * resolution) / resolution.x + 0.5;
  float t = currentTime / 6.0;
  float animationProgress = easeOutQuint(fract(t));

  float intensity = 0.0;

  const float TRAIL_DURATION = 0.7; // Duration of the trail effect
  const int TRAIL_SAMPLES = 32; // Number of samples for the trail

  float2 startPoint = float2(0.7, 0.8);

  // Apply trail effect during the initial animation phase
  if (animationProgress <= TRAIL_DURATION) {
    intensity += trail(uv,
                       t,
                       animationProgress,
                       TRAIL_DURATION,
                       TRAIL_SAMPLES,
                       startPoint,
                       endPoint);
  }
  
  // Apply burst effect after the initial trail duration
  if (animationProgress > TRAIL_DURATION) {
    float timeOffset = animationProgress - TRAIL_DURATION;

    const int RAYS = 8; // Number of rays in the burst
    const float radius = 0.34; // Radius of the burst

    for(int i = 0; i < RAYS; i++) {
      float angle = (float(i) / float(RAYS)) * M_PI_F * 2.0;

      float2 direction = float2(cos(angle), sin(angle));
      float2 burstEnd = endPoint + direction * radius;

      intensity += trail(uv,
                         t,
                         timeOffset,
                         0.27,
                         TRAIL_SAMPLES,
                         endPoint,
                         burstEnd);
    }
  }

  return burstColor * half(min(intensity, 1.0)); // Return the final color with intensity
}
