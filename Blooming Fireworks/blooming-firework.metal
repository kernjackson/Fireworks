// https://uvolchyk.medium.com/blooming-fireworks-with-metal-and-swiftui-6550cef997e2

#import <metal_stdlib>
using namespace metal;

float easeOutQuint(float t) {
  return 1.0 - pow(1.0 - t, 5.0);
}

float noise(float2 co) {
  return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

float rangedInverse(float x, float minRange, float maxRange) {
  float inverse = 0.001 / x;
  float blendFactor = smoothstep(minRange, maxRange, x);
  return inverse * (1.0 - blendFactor);
}

float2 quadraticBezier(float2 p0, float2 p1, float2 p2, float t) {
    float u = 1.0 - t;
    float tt = t * t;
    float uu = u * u;
    float2 p = uu * p0;
    p += 2.0 * u * t * p1;
    p += tt * p2;
    return p;
}

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
  
  float headProgress = animationProgress / animationDuration;

  float2 controlPoint = float2(startPoint.x, startPoint.y - 0.2);
  float2 headPos = quadraticBezier(startPoint, controlPoint, endPoint, headProgress);

  float headDist = distance(uv, headPos);
  if (headDist > 0.4) { return 0.0; }

  for(int i = 0; i < samplesCount * (1.0 - headProgress); i++) {
    float normalizedIndex = float(i) / float(samplesCount);

    float tailRelativeProgress = max(headProgress - normalizedIndex, 0.0);
    if (tailRelativeProgress == 0.0) { continue; }

    float2 tailPointPosition = quadraticBezier(startPoint, controlPoint, endPoint, tailRelativeProgress);

    float particlePos = tailRelativeProgress / headProgress;
    float fadeStart = smoothstep(0.9, 1.0, headProgress);
    float fade = smoothstep(fadeStart, 1.0, particlePos);

    if (normalizedIndex > 0.8 - headProgress) {
      float noiseAmplitude = 0.01;
    
      float noiseValue = noise(float2(float(i) * 0.5 + t * 3.0, t * 2.0)) * 2.0 - 1.0;
      tailPointPosition.y += noiseValue * noiseAmplitude;
      tailPointPosition.x += noiseValue * (noiseAmplitude * 2.0);
    }

    float dist = distance(uv, tailPointPosition);
    float coreGlow = exp(-dist * (100.0 + 200.0 * normalizedIndex * headProgress));
    float bloomGlow = rangedInverse(dist, 0.0, 0.4);

    intensity += (coreGlow + bloomGlow) * fade;
  }

  return intensity;
}

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

  const float TRAIL_DURATION = 0.7;
  const int TRAIL_SAMPLES = 32;

  float2 startPoint = float2(0.7, 0.8);
//  float2 endPoint = float2(0.5, 0.4);

  if (animationProgress <= TRAIL_DURATION) {
    intensity += trail(uv,
                       t,
                       animationProgress,
                       TRAIL_DURATION,
                       TRAIL_SAMPLES,
                       startPoint,
                       endPoint);
  }
  
  if (animationProgress > TRAIL_DURATION) {
    float timeOffset = animationProgress - TRAIL_DURATION;

    const int RAYS = 8;
    const float radius = 0.34;

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

  return burstColor * half(min(intensity, 1.0));
}
