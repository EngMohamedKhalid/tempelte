// ignore_for_file: non_constant_identifier_names

/// API root.
String BASE_URL = 'https://newapp.absherpark.sa/api/v2/';

/// Websocket channel authorisation. Mounted on the API guard, so it expects
/// the bearer token rather than a session cookie.
String BROADCASTING_AUTH = 'broadcasting/auth';

/// Health check.
String PING = 'ping';

// ─── AUTH AND SESSION ──────────────────────────────────────────────────────

/// Request an OTP. `{phone, purpose: login|register|reset}`.
/// Never returns the code. Rate limited per phone and per IP.
String REQUEST_OTP = 'auth/otp';

/// Verify an OTP. `{phone, code, purpose}` → a single-use verification token.
String VERIFY_OTP = 'auth/otp/verify';

/// Register. `{verification_token, name, ...}` → bearer token.
String REGISTER = 'auth/register';

/// Password login. `{phone, password, device}` → bearer token.
String LOGIN = 'auth/login';

/// Passwordless login. `{verification_token, device}` → bearer token.
/// New capability — the shipped app cannot log in without a password.
String LOGIN_OTP = 'auth/login/otp';

/// Reset password. `{verification_token, password}` — requires proof of
/// possession, unlike the legacy endpoint.
String RESET_PASSWORD = 'auth/password/reset';

/// Revokes the current token only.
String LOGOUT = 'auth/logout';

/// Anonymous browsing session. Replaces the hardcoded shared credentials.
String GUEST = 'auth/guest';

/// The authenticated user.
///
/// Three verbs now, all on this one path — so this one constant serves them
/// all. The 2026-09-23 memo suggests a second name, `ME`; it is deliberately
/// not added, because two constants for one path is how a rename goes half
/// done.
///
/// * `GET` — the session.
/// * `PATCH` — edit the profile. Every field optional; send only what changed.
///   A phone change also needs a `verification_token`, and **the number saved
///   is the one that token was issued for**, not the `phone` in the body.
/// * `DELETE` — delete the account. No body, `204`, and every token and push
///   device goes with it. Afterwards clear the token locally: do **not** call
///   [LOGOUT] or `DELETE` [DEVICES], because this token no longer exists.
///   Refused with `422 errors.account` for an open booking, or for a staff
///   account, which the company manages from the console.
String MY_INFO = 'me';

/// Change the password. `PUT {current_password, password,
/// password_confirmation}` → `204` with no body.
///
/// Every **other** device is signed out and this one's token stays valid, so
/// the user is not thrown out of the app they just used. A forgotten password
/// still goes through the OTP reset flow — [REQUEST_OTP] with
/// `purpose: reset`, then [RESET_PASSWORD] — because that one needs no
/// current password.
String MY_PASSWORD = 'me/password';

/// FCM device registration. POST to add, DELETE to remove.
String DEVICES = 'devices';

// ─── CUSTOMER ──────────────────────────────────────────────────────────────

/// Car parks. Send `lat`, `lng` and `radius` to get `distance_km`; without
/// coordinates that field is absent rather than zero.
String PARKINGS = 'parkings';

String PARKING(int id) => 'parkings/$id';

String PARKING_REVIEWS(int id) => 'parkings/$id/reviews';

/// Bookings. Filter the list with `?status=` — a real server-side filter.
/// Creation takes `{parking_id, car_id, note?}`; there is deliberately no
/// `coupon_code`, because nothing reads one back into a price.
String BOOKINGS = 'bookings';

String BOOKING(int id) => 'bookings/$id';

String BOOKING_REQUEST_CAR(int id) => 'bookings/$id/request-car';

String BOOKING_CANCEL(int id) => 'bookings/$id/cancel';

String BOOKING_REVIEW(int id) => 'bookings/$id/review';

/// Creates a payment intent. The Moyasar webhook settles it; the client never
/// asserts success.
String BOOKING_PAYMENTS(int id) => 'bookings/$id/payments';

/// The user's cars. Editing has its own endpoint and takes JSON — the legacy
/// app POSTs to the collection for both create and edit, which silently
/// creates duplicates.
String CARS = 'cars';

String CAR(int id) => 'cars/$id';

/// Renders the car's QR. Off by default; pass `?with_qr=1`.
String CAR_WITH_QR(int id) => 'cars/$id?with_qr=1';

/// The make-and-model catalogue, brands with their models nested.
///
/// Replaces the legacy `driver/cars` — a *driver* endpoint the old app called
/// from the customer's cubit. Sorted by name, models sorted within each brand,
/// **no pagination**: the whole list arrives in one response. It rarely
/// changes, so it is fetched once and kept for the session.
///
/// The ids here are exactly what `POST`/`PATCH` [CARS] and [STAFF_BOOKINGS]
/// want as `car_brand_id` and `car_model_id`. Until this existed there was no
/// way to set either field, so both were shown read-only.
String CAR_BRANDS = 'car-brands';

String VISITS = 'visits';

String VISIT(int id) => 'visits/$id';

/// CMS pages. Each row is a slug, a title and an external URL — there is no
/// body column, so these cannot be rendered inline as-is.
String PAGES = 'pages';

String PAGE(String slug) => 'pages/$slug';

// ─── STAFF ─────────────────────────────────────────────────────────────────
// Gated on role:driver|supervisor. Everything else gets 403.
// Every state change is a named action and every one is a POST; a GET to any
// of them returns 405.

/// The reservations board. `?parking_id=` can only narrow it.
String STAFF_BOARD = 'staff/board';

String STAFF_BOARD_SUMMARY = 'staff/board/summary';

/// Walk-in registration. The customer phone is optional.
String STAFF_BOOKINGS = 'staff/bookings';

String STAFF_ACCEPT(int id) => 'staff/bookings/$id/accept';

String STAFF_REJECT(int id) => 'staff/bookings/$id/reject';

/// `{slot_id?}` — optional, because 99% of bookings have no slot. A taken bay
/// returns 422, not 500.
String STAFF_PARK(int id) => 'staff/bookings/$id/park';

String STAFF_READY(int id) => 'staff/bookings/$id/ready';

/// `{payment_method, amount}` — accepts cash, cod or complimentary only.
/// `online` is 422: the webhook settles it, never the client.
String STAFF_COMPLETE(int id) => 'staff/bookings/$id/complete';

/// `{user_id}` — supervisor only, and the driver must work that car park.
/// A driver calling it gets 403; a `user_id` from another park gets
/// `422 errors.user_id`. The set to choose from comes from
/// [STAFF_PARKING_DRIVERS].
String STAFF_ASSIGN(int id) => 'staff/bookings/$id/assign';

/// Every driver attached to a car park — `{id, name, name_en, phone,
/// on_shift}` — for the supervisor's assign picker.
///
/// **On shift or not.** The legacy `driver/get` listed only drivers currently
/// on shift; this lists them all and flags which, because both kinds can be
/// assigned. Takes the booking's own `parking.id`. A `404` means the caller
/// does not work at that car park.
String STAFF_PARKING_DRIVERS(int parkingId) =>
    'staff/parkings/$parkingId/drivers';

/// Ends a reservation. `{note?}` up to 1000 characters, saved on the booking
/// and visible in the console.
///
/// Any driver or supervisor at the booking's car park may call it. The server
/// releases the bay and sends the customer the push itself, **so the app sends
/// none**. `422 errors.status` when the booking's state does not allow it.
///
/// Not to be confused with [STAFF_REJECT], which hands the job back to the
/// queue as `requested` and does not end the booking.
String STAFF_CANCEL(int id) => 'staff/bookings/$id/cancel';

/// multipart/form-data: `key_number`, `note`, `media[]` (max 10 files, 10 MB
/// each). Does not change the booking status.
String STAFF_KEY(int id) => 'staff/bookings/$id/key';

String STAFF_REQUEST_PAYMENT(int id) => 'staff/bookings/$id/request-payment';

/// Shifts are two verbs, not a toggle — each states its intended end state and
/// does nothing if it already holds.
String STAFF_SHIFTS = 'staff/shifts';

String STAFF_SHIFT_START = 'staff/shifts/start';

String STAFF_SHIFT_END = 'staff/shifts/end';

/// The company's active rate cards for a car park, `{id, name, name_en,
/// is_default}`, default first. `404` means the caller does not work at that
/// park. An empty list means the park prices as it always has — no picker.
String STAFF_PARKING_RATE_CARDS(int parkingId) =>
    'staff/parkings/$parkingId/rate-cards';

String STAFF_SLOTS(int parkingId) => 'staff/parkings/$parkingId/slots';

// ─── CHAT ──────────────────────────────────────────────────────────────────

String CONVERSATIONS = 'conversations';

/// Cursor pagination via `?before=`; `meta.next_before` is null at the start
/// of the thread. Never compute a cursor from an id you happen to hold.
String MESSAGES(int bookingId) => 'bookings/$bookingId/messages';

/// Marking read is an explicit, idempotent action — optionally `{up_to_id}`.
/// The legacy API marks read as a side effect of the GET, so a notification
/// preview clears the badge on a message nobody saw.
String MESSAGES_READ(int bookingId) => 'bookings/$bookingId/messages/read';

// ─── NOT BUILT ─────────────────────────────────────────────────────────────
// Reserved paths, kept so nothing else claims them. Subscriptions and plans
// are out of scope by decision: in production a subscription has never been
// used on a booking.
//
//   GET  plans
//   GET  subscriptions
//   POST subscriptions
//   GET  staff/subscriptions/requested
