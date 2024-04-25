# TODO/consider
# - Complete meta section (is -orig-id allowed/desired there?)
# - Text encoding: some ASCII, some explicitly marked unspecified in RFC.
# - Add doc attributes.
# - Add valid attributes 
# - Lint?
# - time_zone_designations is not a single NUL terminated string, it can
#   contain multiple, possibly overlapping designations.
# - standard_or_walls & ut_or_locals are arrays of bool encoded one per byte.
#   Can kaitai express this? Equivalent of Python `struct.struct('?')`?
# - Should timestamps have named types, or stick with current u4/u8 usage?
#   Does kaitai have type aliases? Any downside to single element seq? 

meta:
  id: tzif
  title: Time Zone Information Format
  xref:
    rfc: 8536
  encoding: ascii  # FIXME convenience during prototype, not true in general
  endian: be
seq:
  - id: header_v1
    type: header
  - id: data_v1
    type: data_block_v1
  - id: header_v2
    type: header
    if: header_v1.version != version::v1
  - id: data_v2
    type: data_block_v2
    if: header_v1.version != version::v1
  - id: footer
    type: footer
    if: header_v1.version != version::v1
types:
  header:
    seq:
      - id: magic
        contents: TZif
      - id: version
        type: u1
        enum: version
      - id: reserved
        size: 15
        type: str
      - id: num_ut_or_locals
        -orig-id: isutscnt
        type: u4
      - id: num_standard_or_walls
        -orig-id: isstdcnt
        type: u4
      - id: num_leap_seconds
        -orig-id: leapcnt
        type: u4
      - id: num_transition_times
        -orig-id: timecnt
        type: u4
      - id: num_local_time_types
        -orig-id: typecnt
        type: u4
      - id: len_time_zone_designations
        -orig-id: chrcnt
        type: u4
  data_block_v1:
    seq:
      - id: transition_times
        type: s4
        repeat: expr
        repeat-expr: _root.header_v1.num_transition_times
      - id: transition_types
        type: s1
        repeat: expr
        repeat-expr: _root.header_v1.num_transition_times
      - id: local_time_types
        type: local_time_type
        repeat: expr
        repeat-expr: _root.header_v1.num_local_time_types
      - id: time_zone_designations
        size: _root.header_v1.len_time_zone_designations
        type: str
      - id: leap_seconds
        type: leap_second_v1
        repeat: expr
        repeat-expr: _root.header_v1.num_leap_seconds
      - id: standard_or_walls
        type: u1
        repeat: expr
        repeat-expr: _root.header_v1.num_standard_or_walls
      - id: ut_or_locals
        type: u1
        repeat: expr
        repeat-expr: _root.header_v1.num_ut_or_locals
  data_block_v2:
    seq:
      - id: transition_times
        type: s8
        repeat: expr
        repeat-expr: _root.header_v2.num_transition_times
      - id: transition_types
        type: s1
        repeat: expr
        repeat-expr: _root.header_v2.num_transition_times
      - id: local_time_types
        type: local_time_type
        repeat: expr
        repeat-expr: _root.header_v2.num_local_time_types
      - id: time_zone_designations
        type: str
        size: _root.header_v2.len_time_zone_designations
      - id: leap_seconds
        type: leap_second_v2
        repeat: expr
        repeat-expr: _root.header_v2.num_leap_seconds
      - id: standard_or_walls
        type: u1
        repeat: expr
        repeat-expr: _root.header_v2.num_standard_or_walls
      - id: ut_or_locals
        type: u1
        repeat: expr
        repeat-expr: _root.header_v2.num_ut_or_locals
  local_time_type:
    seq:
      - id: ut_offset
        type: s4
      - id: is_dst
        type: u1
      - id: time_zone_designation_idx
        type: u1
  leap_second_v1:
    seq:
      - id: occurence
        type: s4
      - id: correction
        type: s4
  leap_second_v2:
    seq:
      - id: occurence
        type: s8
      - id: correction
        type: s4
  footer:
    seq:
      - id: magic
        contents: "\n"  # ASCII NL
      - id: time_zone_string
        -orig-id: tz_string
        type: str
        terminator: 0x0a  # ASCII NL
enums:
  version:
    0x00: v1  # ASCII NUL
    0x32: v2  # ASCII "2"
    0x33: v3  # ASCII "3"
    0x34: v4  # ASCII "4"
