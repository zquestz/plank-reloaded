/**
 * plank_easing_for_mode:
 * @self: the (null) instance
 * @mode: (in): &nbsp;.  <para>animation-mode to be used </para>
 * @t: (in): &nbsp;.  <para>elapsed time </para>
 * @d: (in): &nbsp;.  <para>total duration </para>
 * 
 * Calculate an interpolated value for selected animation-mode, and given elapsed time and total duration.
 * 
 * Returns: <para>the interpolated value, between -1.0 and 2.0 </para>
 */
/**
 * PlankAnimationMode:
 * @PLANK_ANIMATION_MODE_LINEAR: linear tweening
 * @PLANK_ANIMATION_MODE_EASE_IN_QUAD: quadratic tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_QUAD: quadratic tweening, inverse of EASE_IN_QUAD
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_QUAD: quadratic tweening, combininig EASE_IN_QUAD and EASE_OUT_QUAD
 * @PLANK_ANIMATION_MODE_EASE_IN_CUBIC: cubic tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_CUBIC: cubic tweening, invers of EASE_IN_CUBIC
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_CUBIC: cubic tweening, combining EASE_IN_CUBIC and EASE_OUT_CUBIC
 * @PLANK_ANIMATION_MODE_EASE_IN_QUART: quartic tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_QUART: quartic tweening, inverse of EASE_IN_QUART
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_QUART: quartic tweening, combining EASE_IN_QUART and EASE_OUT_QUART
 * @PLANK_ANIMATION_MODE_EASE_IN_QUINT: quintic tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_QUINT: quintic tweening, inverse of EASE_IN_QUINT
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_QUINT: fifth power tweening, combining EASE_IN_QUINT and EASE_OUT_QUINT
 * @PLANK_ANIMATION_MODE_EASE_IN_SINE: sinusoidal tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_SINE: sinusoidal tweening, inverse of EASE_IN_SINE
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_SINE: sine wave tweening, combining EASE_IN_SINE and EASE_OUT_SINE
 * @PLANK_ANIMATION_MODE_EASE_IN_EXPO: exponential tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_EXPO: exponential tweening, inverse of EASE_IN_EXPO
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_EXPO: exponential tweening, combining EASE_IN_EXPO and EASE_OUT_EXPO
 * @PLANK_ANIMATION_MODE_EASE_IN_CIRC: circular tweening
 * @PLANK_ANIMATION_MODE_EASE_OUT_CIRC: circular tweening, inverse of EASE_IN_CIRC
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_CIRC: circular tweening, combining EASE_IN_CIRC and EASE_OUT_CIRC
 * @PLANK_ANIMATION_MODE_EASE_IN_ELASTIC: elastic tweening, with offshoot on start
 * @PLANK_ANIMATION_MODE_EASE_OUT_ELASTIC: elastic tweening, with offshoot on end
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_ELASTIC: elastic tweening with offshoot on both ends
 * @PLANK_ANIMATION_MODE_EASE_IN_BACK: overshooting cubic tweening, with backtracking on start
 * @PLANK_ANIMATION_MODE_EASE_OUT_BACK: overshooting cubic tweening, with backtracking on end
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_BACK: overshooting cubic tweening, with backtracking on both ends
 * @PLANK_ANIMATION_MODE_EASE_IN_BOUNCE: exponentially decaying parabolic (bounce) tweening, with bounce on start
 * @PLANK_ANIMATION_MODE_EASE_OUT_BOUNCE: exponentially decaying parabolic (bounce) tweening, with bounce on end
 * @PLANK_ANIMATION_MODE_EASE_IN_OUT_BOUNCE: exponentially decaying parabolic (bounce) tweening, with bounce on both ends
 * 
 * The available animation modes
 */
