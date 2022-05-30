// MeetTalkConfigs.h

// Call Message Action
#define CALL_INITIATED @"call/initiate"
#define CALL_CANCELLED @"call/cancel"
#define CALL_ENDED @"call/end"
#define RECIPIENT_ANSWERED_CALL @"call/answer"
#define RECIPIENT_BUSY @"call/busy"
#define RECIPIENT_REJECTED_CALL @"call/reject"
#define RECIPIENT_MISSED_CALL @"call/timeout"
#define RECIPIENT_UNABLE_TO_RECEIVE_CALL @"call/unable"
#define PARTICIPANT_JOINED_CONFERENCE @"conference/join"
#define PARTICIPANT_LEFT_CONFERENCE @"conference/left"
#define CONFERENCE_INFO @"conference/info"

// Call Message Type
#define CALL_MESSAGE_TYPE 8001

// Conference Info Key
#define CONFERENCE_MESSAGE_DATA @"meetTalkConferenceInfo"

// Participant Role
#define HOST @"host"
#define MODERATOR @"moderator"
#define PARTICIPANT @"participant"

// Url
#define MEET_URL @"https://meet.taptalk.io"
#define MEET_ROOM_ID_PREFIX @"meet-taptalk-io-"

// Value
#define DEFAULT_CALL_TIMEOUT_DURATION 120000L

// Jitsi Meet Broadcast Event Type
#define CONFERENCE_JOINED @"org.jitsi.meet.CONFERENCE_JOINED"
#define CONFERENCE_TERMINATED @"org.jitsi.meet.CONFERENCE_TERMINATED"
#define CONFERENCE_WILL_JOIN @"org.jitsi.meet.CONFERENCE_WILL_JOIN"
#define AUDIO_MUTED_CHANGED @"org.jitsi.meet.AUDIO_MUTED_CHANGED"
#define PARTICIPANT_JOINED @"org.jitsi.meet.PARTICIPANT_JOINED"
#define PARTICIPANT_LEFT @"org.jitsi.meet.PARTICIPANT_LEFT"
#define ENDPOINT_TEXT_MESSAGE_RECEIVED @"org.jitsi.meet.ENDPOINT_TEXT_MESSAGE_RECEIVED"
#define SCREEN_SHARE_TOGGLED @"org.jitsi.meet.SCREEN_SHARE_TOGGLED"
#define RETRIEVE_PARTICIPANTS_INFO @"org.jitsi.meet.RETRIEVE_PARTICIPANTS_INFO"
#define PARTICIPANTS_INFO_RETRIEVED @"org.jitsi.meet.PARTICIPANTS_INFO_RETRIEVED"
#define CHAT_MESSAGE_RECEIVED @"org.jitsi.meet.CHAT_MESSAGE_RECEIVED"
#define CHAT_TOGGLED @"org.jitsi.meet.CHAT_TOGGLED"
#define VIDEO_MUTED_CHANGED @"org.jitsi.meet.VIDEO_MUTED_CHANGED"

// Jitsi Meet Flags

/**
 * Flag indicating if add-people functionality should be enabled.
 * Default: enabled (true).
 */
#define ADD_PEOPLE_ENABLED @"add-people.enabled"

/**
 * Flag indicating if the SDK should not require the audio focus.
 * Used by apps that do not use Jitsi audio.
 * Default: disabled (false).
 */
#define AUDIO_FOCUS_DISABLED @"audio-focus.disabled"

/**
 * Flag indicating if the audio mute button should be displayed.
 * Default: enabled (true).
 */
#define AUDIO_MUTE_BUTTON_ENABLED @"audio-mute.enabled"

/**
 * Flag indicating that the Audio only button in the overflow menu is enabled.
 * Default: enabled (true).
 */
#define AUDIO_ONLY_BUTTON_ENABLED @"audio-only.enabled"

/**
 * Flag indicating if calendar integration should be enabled.
 * Default: enabled (true) on Android, auto-detected on iOS.
 */
#define CALENDAR_ENABLED @"calendar.enabled"

/**
 * Flag indicating if call integration (CallKit on iOS, ConnectionService on Android)
 * should be enabled.
 * Default: enabled (true).
 */
#define CALL_INTEGRATION_ENABLED @"call-integration.enabled"

/**
 * Flag indicating if close captions should be enabled.
 * Default: enabled (true).
 */
#define CLOSE_CAPTIONS_ENABLED @"close-captions.enabled"

/**
 * Flag indicating if conference timer should be enabled.
 * Default: enabled (true).
 */
#define CONFERENCE_TIMER_ENABLED @"conference-timer.enabled"

/**
 * Flag indicating if chat should be enabled.
 * Default: enabled (true).
 */
#define CHAT_ENABLED @"chat.enabled"

/**
 * Flag indicating if the filmstrip should be enabled.
 * Default: enabled (true).
 */
#define FILMSTRIP_ENABLED @"filmstrip.enabled"

/**
 * Flag indicating if fullscreen (immersive) mode should be enabled.
 * Default: enabled (true).
 */
#define FULLSCREEN_ENABLED @"fullscreen.enabled"

/**
 * Flag indicating if the Help button should be enabled.
 * Default: enabled (true).
 */
#define HELP_BUTTON_ENABLED @"help.enabled"

/**
 * Flag indicating if invite functionality should be enabled.
 * Default: enabled (true).
 */
#define INVITE_ENABLED @"invite.enabled"

/**
 * Flag indicating if recording should be enabled in iOS.
 * Default: disabled (false).
 */
#define IOS_RECORDING_ENABLED @"ios.recording.enabled"

/**
 * Flag indicating if screen sharing should be enabled in iOS.
 * Default: disabled (false).
 */
#define IOS_SCREENSHARING_ENABLED @"ios.screensharing.enabled"

/**
 * Flag indicating if screen sharing should be enabled in android.
 * Default: enabled (true).
 */
#define ANDROID_SCREENSHARING_ENABLED @"android.screensharing.enabled"

/**
 * Flag indicating if speaker statistics should be enabled.
 * Default: enabled (true).
 */
#define SPEAKERSTATS_ENABLED @"speakerstats.enabled"

/**
 * Flag indicating if kickout is enabled.
 * Default: enabled (true).
 */
#define KICK_OUT_ENABLED @"kick-out.enabled"

/**
 * Flag indicating if live-streaming should be enabled.
 * Default: auto-detected.
 */
#define LIVE_STREAMING_ENABLED @"live-streaming.enabled"

/**
 * Flag indicating if lobby mode button should be enabled.
 * Default: enabled.
 */
#define LOBBY_MODE_ENABLED @"lobby-mode.enabled"

/**
 * Flag indicating if displaying the meeting name should be enabled.
 * Default: enabled (true).
 */
#define MEETING_NAME_ENABLED @"meeting-name.enabled"

/**
 * Flag indicating if the meeting password button should be enabled.
 * Note that this flag just decides on the button, if a meeting has a password
 * set, the password dialog will still show up.
 * Default: enabled (true).
 */
#define MEETING_PASSWORD_ENABLED @"meeting-password.enabled"

/**
 * Flag indicating if the notifications should be enabled.
 * Default: enabled (true).
 */
#define NOTIFICATIONS_ENABLED @"notifications.enabled"

/**
 * Flag indicating if the audio overflow menu button should be displayed.
 * Default: enabled (true).
 */
#define OVERFLOW_MENU_ENABLED @"overflow-menu.enabled"

/**
 * Flag indicating if Picture-in-Picture should be enabled.
 * Default: auto-detected.
 */
#define PIP_ENABLED @"pip.enabled"

/**
 * Flag indicating if raise hand feature should be enabled.
 * Default: enabled.
 */
#define RAISE_HAND_ENABLED @"raise-hand.enabled"

/**
 * Flag indicating if the reactions feature should be enabled.
 * Default: enabled (true).
 */
#define REACTIONS_ENABLED @"reactions.enabled"

/**
 * Flag indicating if recording should be enabled.
 * Default: auto-detected.
 */
#define RECORDING_ENABLED @"recording.enabled"

/**
 * Flag indicating if the user should join the conference with the replaceParticipant functionality.
 * Default: (false).
 */
#define REPLACE_PARTICIPANT @"replace.participant"

/**
 * Flag indicating the local and (maximum) remote video resolution. Overrides
 * the server configuration.
 * Default: (unset).
 */
#define RESOLUTION @"resolution"

/**
 * Flag indicating if the security options button should be enabled.
 * Default: enabled (true).
 */
#define SECURITY_OPTIONS_ENABLED @"security-options.enabled"

/**
 * Flag indicating if server URL change is enabled.
 * Default: enabled (true).
 */
#define SERVER_URL_CHANGE_ENABLED @"server-url-change.enabled"

/**
 * Flag indicating if tile view feature should be enabled.
 * Default: enabled.
 */
#define TILE_VIEW_ENABLED @"tile-view.enabled"

/**
 * Flag indicating if the toolbox should be always be visible
 * Default: disabled (false).
 */
#define TOOLBOX_ALWAYS_VISIBLE @"toolbox.alwaysVisible"

/**
 * Flag indicating if the toolbox should be enabled
 * Default: enabled.
 */
#define TOOLBOX_ENABLED @"toolbox.enabled"

/**
 * Flag indicating if the video mute button should be displayed.
 * Default: enabled (true).
 */
#define VIDEO_MUTE_BUTTON_ENABLED @"video-mute.enabled"

/**
 * Flag indicating if the video share button should be enabled
 * Default: enabled (true).
 */
#define VIDEO_SHARE_BUTTON_ENABLED @"video-share.enabled"

/**
 * Flag indicating if the welcome page should be enabled.
 * Default: disabled (false).
 */
#define WELCOME_PAGE_ENABLED @"welcomepage.enabled"
