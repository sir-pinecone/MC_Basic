/*==================================================================================================
  File: mc_basic.jai
  Creation Date: 2023-01-04
  Creator: Michael Campagnaro
  Version: 0.1.022
  Notice: (C) Copyright 2023-2025 by Jelly Pixel, Inc. All Rights Reserved.
  ================================================================================================*/

//
// The exit handler is set once for an application, e.g. in main.jai.
// Can pass your own exit handler or use the default exit() / explicity pass exit().
//
//  e.g.
//
//  #import "MC_Basic"()(DEVELOPER=true, xexit=my_custom_exit);
//  my_custom_exit :: (code: s32) { ... }
//

#module_parameters()(DEVELOPER := false, SHOW_CODE_IN_STACK_TRACE := true, xexit: (s32) = code => { exit(code); });

#load "types.jai";

/*
Routines in this file:
    ////// MISC ///////

    clear :: Initialize;

    offset_of     :: ($struct_type: Type, $field: string) -> s64
    size_of_field :: ($struct_type: Type, $field: string) -> s64

    has_any_flags :: inline (flags: $T, test_flags: T) -> bool
    has_all_flags :: inline (flags: $T, test_flags: T) -> bool

    make_random_seed :: () -> u64;

    // From bytes.
    TO_KB :: (n: $T) -> f64 #expand
    TO_MB :: (n: $T) -> f64 #expand
    TO_GB :: (n: $T) -> f64 #expand

    // To bytes.
    KB :: (n: u64) -> u64 #expand
    MB :: (n: u64) -> u64 #expand
    GB :: (n: u64) -> u64 #expand

    human_readable_bytes :: (bytes: u64, trailing_width := 1) -> string

    pointer_diff :: (a: *$T, b: *$U) -> s64 #expand

    get_git_commit_hash :: () -> string

    ////// ASSERT & ERROR //////

    mc_assert :: ($c: Code, format_string := "", args: ..Any, loc := #caller_location) #expand #no_debug

    assert_enum_value_with_name :: (enum_value: $T, index: int, name: string) -> string #expand #compile_time

    mc_assertion_failed :: (loc: Source_Code_Location, message: string) -> bool
    show_assert_dialog :: (loc: Source_Code_Location, message: string) -> Assert_Dialog_Response

    crash :: (format_string := "", args: .. Any, loc := #caller_location, action_name := "CRASH")
    unimplemented     :: #bake_arguments crash(action_name="UNIMPLEMENTED");
    invalid_code_path :: #bake_arguments crash(action_name="INVALID CODE PATH")

    mc_crash_handler :: (stack_trace: [] string)
    show_crash_dialog :: (loc: Source_Code_Location, message: string, action_name: string) -> break_or_minidump: bool

    print_stack_trace_with_code :: (node: *Stack_Trace_Node, to_standard_error := true)

    make_assert_allocator :: () -> Allocator
    assert_allocator_proc :: (mode: Allocator_Mode, requested_size: s64, old_size: s64, old_memory: *void, allocator_data: *void, loc := #caller_location) -> *void

    ////// LOGGING & PRINTING //////

    format_os_error :: #bake_arguments formatInt(base=16)

    color_print :: (color: Console_Color, format_string: string, args: .. Any) // thread-safe
    print_error :: #bake_arguments color_print(color=.RED)
    print_warn  :: #bake_arguments color_print(color=.YELLOW)

    log_warn :: (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null)

    dlog         :: (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null)
    dlog_warn    :: (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null)
    dlog_error   :: (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null)
    dprint       :: (format_string: string, args: ..Any)
    dcolor_print :: (color: Console_Color, s: string, args: ..Any)
    dprint_error :: (format_string: string, args: ..Any)
    dprint_warn  :: (format_string: string, args: ..Any)

    log_struct   :: (value: Any)
    print_struct :: (value: Any)

    log_cpu_info :: ()

    log_temp_storage_use   :: inline ()
    print_temp_storage_use :: inline ()

    fmt1 :: (value: f64) -> FormatFloat #expand
    fmt2 :: (value: f64) -> FormatFloat #expand

    ////// ARRAYS //////

    clear_array :: (array: [] $T)
    clear_array :: (array: [] $T, value: T)

    resizable_array   :: ($T: Type, capacity := 8) -> [..] T

    efficient_remove :: (captured: *[] $T) -> Efficient_Remove(T)

    array_find :: (array: [] $T, f: (T) -> $R, value: R) -> T, s64

    array_contains :: (array: [] $T, item: T) -> bool, index: s64
    array_contains_code :: (array: [] $T, code: Code) -> bool #expand

    map :: (array: [] $T, f: (T) -> $R) -> [..] R
    map_code :: (array: [] $T, $R: Type, code: Code) -> [..] R #expand

    filter :: (array: [] $T, f: (T) -> bool) -> [..] T
    filter_code :: (array: [] $T, code: Code) -> [..] T #expand
    filter :: (array: *[] $T, f: (T) -> bool) -> [..] *T
    filter_code :: (array: *[] $T, code: Code) -> [..] *T #expand

    random_choice :: inline (state: *Random_State, count: u64) -> u64
    random_choice :: inline (state: *Random_State, arr: [] $T) -> u64
    shuffle :: (array: [] $T)

    ////// STRINGS //////

    quick_string_builder :: () #expand

    fast_string :: inline (s: string, index: s64, count: s64) -> string
    fast_string :: inline (s: *u8, index: s64, count: s64) -> string

    free_string :: (s: *string)

    to_string :: inline (c: u8) -> string

    string_to_apollo :: (s: string) -> success: bool, Apollo_Time

    find_index_from_left_nocase :: (s: string, substring: string, start_index := 0) -> s64

    trim_line_endings :: inline (s: string) -> string
    trim_line_endings :: inline (s: *string)

    lines_of :: (s: *string, body: Code, flags: For_Flags) #expand

    read_line_from_console :: (buffer: string) -> success: bool, string

    plural :: inline (x: int) -> string

    repeat :: (s: string, times: int) -> string

    repeat_char :: (character: u8, count: s64) -> string

    split_by_spaces :: (s: string, ignore_empty_values: bool) -> [] string;

    truncate :: (s: string, index_start: int, index_end: int) -> string
    truncate :: (s: $T, index_start: int) -> string

    left_pad :: (source: $T/.[string, u8], total_length: int, pad_char: u8 = " ") -> string
    right_pad :: (source: $T/.[string, u8], total_length: int, pad_char: u8 = " ") -> string

    get_proc_name :: ($c: Code) -> string #expand

    get_identifier_name :: ($c: Code) -> string #compile_time

    calendar_to_log_name_string :: (ct: Calendar_Time) -> string /* temporary allocator */

    ////// FILES //////

    safe_string_for_filename :: (s: string) -> string

    file_or_directory_exists :: (path: string)     -> success: bool, exists: bool, is_dir: bool  /* temporary allocator */ #deprecated
    file_or_directory_exists_new :: (path: string) -> success: bool, exists: bool, is_file: bool /* temporary allocator */

    log_path_existence_on_the_local_filesystem :: (path_str: string, message: string = "", show_hint_about_colored_text := true) /* temporary allocator */

    get_reduced_path :: (path: string) -> string /* temporary allocator */

    verify_path_exists :: (path: string, shortname: string, $expected_kind: enum { NONE; FILE; DIR; }) -> exists: bool, is_file: bool

    get_absolute_path :: (path: string, $normalize_slashes := true, $use_cwd := false, $reduce_path := false) -> string, already_absolute: bool /* temporary allocator */ {

    is_an_absolute_path :: (path: string) -> bool

    is_root_drive_path :: (path: string) -> bool

    copy_file_with_overwriting :: (source: string, dest: string, overwrite_if_exists := false) -> bool

    delete_directory_recursively :: (path: string) -> bool;
    delete_empty_directory :: (path: string) -> bool;
    delete_old_files :: (keep_last: int, directory_name := "logs")

    file_rename :: file_move

    ////// MATH ///////

    is_pow2 :: inline (x: u32) -> bool

    floor :: (f: v2) -> v2
    floor :: (f: v3) -> v3

    eerp :: (a, b, t) -> something // @incomplete

    move_toward :: (a_pointer: *float, target: float, dt: float, rate_up: float, rate_down: float = -1.0)
    move_toward :: (a_pointer: *v2, target: v2, dt: float, rate_up: float, rate_down: float = -1.0)

    ////// METAPROGRAMMING //////

    default_of :: ($T: Type) -> T #expand

    ModifyRequire :: (t: Type, kind: Type_Info_Tag)
    expect_specified :: ($T: Type) #compile_time

    align_of :: (ti: *Type_Info) -> int #compile_time
    align_of :: ($T: Type) -> int #compile_time

    enum_count :: (e: $T) -> s64

    enum_iterator :: ($T: Type) -> Enum_Iterator(T)

    enum_iterator_s64 :: ($T: Type) -> Enum_Iterator_s64(T)

    enum_value_iterator :: ($T: Type) -> Enum_Value_Iterator(T)

    make_enum_name_array :: ($t: Type) -> string #compile_time #modify ModifyRequire(t, .ENUM)
*/

///////////////////////////////////////////////////////////////////////////////////////
// # MISC
///////////////////////////////////////////////////////////////////////////////////////

// Calls the initializer on the passed in pointer if it exists, otherwise memsets it to 0.
clear :: Initialize;

offset_of :: ($T: Type, $field: string, loc := #caller_location) -> int #expand {
    return #run -> int {
        for type_info(T).members if it.name == field {
            return it.offset_in_bytes;
        }
        assert(false, "Type '%' does not have a field named '%'", T, field, loc=loc);
        return -1;
    };
}

// WARNING: if you use this at compile-time then the runtime_size might be
// unset if compilatiton isn't finished. It will be -1 in this case. It can
// also be -1 if the type is polymorphic. This warning is from the Type_Info
// struct.
size_of_field :: ($T: Type, $field: string, loc := #caller_location) -> int #expand {
    return #run -> int {
        for type_info(T).members if it.name == field {
            return it.type.runtime_size;
        }
        assert(false, "Type '%' does not have a field named '%'", T, field, loc=loc);
        return -1;
    };
}

has_any_flags :: inline (flags: $T, test_flags: T) -> bool {
    return (flags & test_flags) != 0;
}

has_all_flags :: inline (flags: $T, test_flags: T) -> bool {
    return (flags & test_flags) == test_flags;
}

// Get a better random seed than just using the monotonic value directly, which has
// some static lower bits and can result in you getting the same random values
// across multiple runs of a process within a certain timeframe.
// From https://discord.com/channels/661732390355337246/661732390355337249/1354904553245642944
make_random_seed :: () -> u64 {
    time := current_time_monotonic().low;
    result := (get_hash(time >> 16).(u64) << 32) | get_hash(time);
    return result;
}

// From bytes.
TO_KB :: (n: $T) -> f64 #expand { return n / 1024.0; }
TO_MB :: (n: $T) -> f64 #expand { return n / (1024.0 * 1024.0); }
TO_GB :: (n: $T) -> f64 #expand { return n / (1024.0 * 1024.0 * 1024.0); }

// To bytes.
KB :: (n: u64) -> u64 #expand { return n * 1024; }
MB :: (n: u64) -> u64 #expand { return n * 1024 * 1024; }
GB :: (n: u64) -> u64 #expand { return n * 1024 * 1024 * 1024; }

human_readable_bytes :: (bytes: u64, trailing_width := 1) -> string {
    size: f64 = ---;
    unit: string = ---;

    if bytes >= 1024 * 1024 * 1024 {
        size = bytes / (1024.0 * 1024.0 * 1024.0);
        unit = "GB";
    } else if bytes >= 1024 * 1024 {
        size = bytes / (1024.0 * 1024.0);
        unit = "MB";
    } else if bytes >= 1024 {
        size = bytes / 1024.0;
        unit = "KB";
    } else {
        size = xx bytes;
        unit = "B";
    }

    result := tprint("% %", FormatFloat.{value=size, trailing_width=trailing_width, zero_removal=.NO}, unit);

    return result;
}

pointer_diff :: (a: *$T, b: *$U) -> s64 #expand {
    return cast(s64)((cast(*u8) a) - (cast(*u8) b));
}

get_git_commit_hash :: () -> string {
    result, revision := run_command("git", "rev-parse", "--short", "HEAD", capture_and_return_output = true);
    assert(!result.exit_code);
    if revision return trim(revision);
    return "???";
}

///////////////////////////////////////////////////////////////////////////////////////
// # ASSERT & ERRORS
///////////////////////////////////////////////////////////////////////////////////////

// @incomplete maybe change this to USE_ASSERT instead of DEVELOPER ?
#if DEVELOPER {
    // This assert macro prints the values of binary operators and optionally
    // the source code of the stack trace. To enable the code output, import
    // this module and set SHOW_CODE_IN_STACK_TRACE to true. If enabled, you
    // need to use the mc_assertion_failed proc in order to report correct line
    // numbers.
    //
    // Example:
    //
    //    using,except(assert) Basic :: #import "Basic";
    //    assert :: mc_assert;
    //
    //    main :: () {
    //        context.assertion_failed = mc_assertion_failed; // Replace the default handler.
    //    }
    //
    mc_assert :: ($code: Code, format_string := "", args: ..Any, loc := #caller_location) #expand #no_debug {
        // Modified version of ctp's code (user in beta discord): https://gist.github.com/conorpetersen/840d15920a825944dcbe5c0a574a96aac
        //
        // This procedure splits a binary operator into its lhs and rhs
        // expressions, and evaluates and prints them separately for the
        // purpose of providing a better assert message. Multiple evaluation
        // cannot be completely avoided, but asserts aren't supposed to have
        // side effects anyway, so this is fine.
        //
        // Expression like 'size == .BIG' or 'xy != .{ 0.0, 0.0 }' cause
        // problems because 'rhs := .BIG' or 'rhs := .{ 0.0, 0.0 }' cannot be
        // evaluated separate from the expression.
        //
        // The left and right printing isn't done for binary expressions that
        // are accessing a pointer/struct/string member. e.g. assert(my_ptr.some_member), assert(str.count)
        //
        // For an assert with a binary operator as its root, this splits the
        // expression and prints each side separately, e.g.
        //
        //   x := 8;
        //   assert(x + 2 == 5);
        //
        // might print:
        //
        //   lhs has value '8' from expression 'x + 2'.
        //   rhs has value '5' from expression '5'.
        //

        is_binary_operator, expr_string, lhs_code, rhs_code, lhs_can_be_inserted, rhs_can_be_inserted, lhs_text, rhs_text :: #run () -> bool, string, Code, Code, bool, bool, string, string {
            expression_to_string :: (node: *Code_Node) -> string {
                builder: String_Builder;
                builder.allocator = temp;
                PP.print_expression(*builder, node);
                return builder_to_string(*builder,, temp);
            }

            root := compiler_get_nodes(code);
            expr_string := expression_to_string(root);

            if root.kind == .BINARY_OPERATOR {
                root_op := cast(*Code_Binary_Operator) root;

                // UNARY_OPERATOR is enum values like '.BIG'.
                // Struct literals cannot be inserted when they don't have an explicit type like '.{ 0.0, 0.0 }'.

                lhs_can_be_inserted, rhs_can_be_inserted := true, true;

                if root_op.left.kind == .UNARY_OPERATOR {
                    lhs_op := cast(*Code_Unary_Operator) root_op.left;
                    lhs_can_be_inserted = lhs_op.operator_type != #char ".";
                }
                else if root_op.left.kind == .LITERAL {
                    lhs_literal := cast(*Code_Literal) root_op.left;
                    if lhs_literal.value_type == .STRUCT && lhs_literal.struct_literal_info.type_expression == null {
                        lhs_can_be_inserted = false;
                    }
                    // No need to #insert a number; just print the value.
                    if lhs_literal.value_type == .NUMBER {
                        lhs_can_be_inserted = false;
                    }
                }
                else if root_op.left.kind == .IDENT {
                    ident := cast(*Code_Ident) root_op.left;
                    lhs_type := ident.type.type;
                    if lhs_type == .POINTER || lhs_type == .STRUCT || lhs_type == .STRING {
                        // Don't print out the left and right side values because we'll
                        // get a compilation error when trying to insert the rhs code.
                        return false, expr_string, #code {}, #code {}, false, false, "", "";
                    }
                }

                if root_op.right.kind == .UNARY_OPERATOR {
                    rhs_op := cast(*Code_Unary_Operator) root_op.right;
                    rhs_can_be_inserted = rhs_op.operator_type != #char ".";
                }
                else if root_op.right.kind == .LITERAL {
                    rhs_literal := cast(*Code_Literal) root_op.right;
                    if rhs_literal.value_type == .STRUCT && rhs_literal.struct_literal_info.type_expression == null {
                        rhs_can_be_inserted = false;
                    }
                    // No need to #insert a number; just print the value.
                    if rhs_literal.value_type == .NUMBER {
                        rhs_can_be_inserted = false;
                    }
                }

                lhs_code, rhs_code := compiler_get_code(root_op.left), compiler_get_code(root_op.right);
                lhs_text, rhs_text := expression_to_string(root_op.left), expression_to_string(root_op.right);

                return true, expr_string, lhs_code, rhs_code, lhs_can_be_inserted, rhs_can_be_inserted, lhs_text, rhs_text;
            } else {
                return false, expr_string, #code {}, #code {}, false, false, "", "";
            }
        }();

        value := cast(bool) #insert code;
        if value return;

        if context.handling_assertion_failure then return; // Avoid infinite loops.
        context.handling_assertion_failure = true;

        builder: String_Builder;
        builder.allocator = temp;

        if format_string {
            message := tprint(format_string, ..args);
            append(*builder, message);

            if message[message.count-1] != "\n"
                then append(*builder, "\n\n");
                else append(*builder, "\n");
        }

        print(*builder, "Expected '%' to be true.\n\n", expr_string);

        #if is_binary_operator {
            #if lhs_can_be_inserted {
                lhs_value := #insert,scope(code) lhs_code;
                print(*builder, "lhs is '%' from expression '%'\n", lhs_value, lhs_text);
            }
            else print(*builder, "lhs is '%'\n", lhs_text);

            #if rhs_can_be_inserted {
                rhs_value := #insert,scope(code) rhs_code;
                print(*builder, "rhs is '%' from expression '%'\n", rhs_value, rhs_text);
            }
            else print(*builder, "rhs is '%'\n", rhs_text);
        }

        break_or_minidump := context.assertion_failed(loc, builder_to_string(*builder,, temp));
        context.handling_assertion_failure = false;

        if break_or_minidump {
            debug_break();
            xexit(1); // Need this in case we start to debug and they continue execution. :MaybeTerminateForStability
        }
    }

    invalid_code_path :: #bake_arguments crash(action_name="INVALID CODE PATH");
    unimplemented     :: #bake_arguments crash(action_name="UNIMPLEMENTED");

    assert_enum_value_with_name :: (enum_value: $T, index: int, name: string) -> string #expand #compile_time {
        #assert(enum_value == index);
        return name;
    }
} else {
    // @fixme I can't add #discard to the assert params. Causes an internal compiler crash. Might report it some day.
    mc_assert :: ($c: Code, message := "", args: ..Any, loc := #caller_location) #expand #no_debug {}

    invalid_code_path :: (loc := #caller_location) #expand { crash(loc=loc); }
    unimplemented     :: (loc := #caller_location) #expand { crash(loc=loc); }

    assert_enum_value_with_name :: (enum_value: $T, index: int, name: string) -> string #expand #compile_time {
        return name;
    }
}

// Custom assertion failure proc. Will fix the reported line number of the
// failed assertion (happens when using this with a macro assert).
//
// To use this, change the context like so:
//
//    context.assertion_failed = mc_assertion_failed;
//
// Modified version from Arnaud Valensi https://gist.github.com/ArnaudValensi/9f0077bad262b96408e3dae47866f82d
mc_assertion_failed :: (loc: Source_Code_Location, message: string) -> bool {
    werr("\n!!!!!!!!!!!!!!!!!!!!!!!!! ASSERTION FAILED !!!!!!!!!!!!!!!!!!!!!!!!!\n");
    write_error_loc(loc);

    stack_start := context.stack_trace;
    if stack_start {
        // Attempt to skip the top-level entry of the stack trace, which will be this procedure. :WalkBackStack
        // If using a version of the compiler < 0.1.077 then this will need to be handled differently with line
        // number patching and special handling when this proc is called from a macro. See the previous commit
        // of this file for that code.
        if stack_start.next then stack_start = stack_start.next;

        if stack_start.info && stack_start.info.name {
            werrs("Proc: ", stack_start.info.name, "\n");
        }
    }

    if message {
        if message[message.count-1] != "\n"
            then werrs("\n", message, "\n\n");
            else werrs("\n", message, "\n");
    } else {
        werr("\n");
    }

    if stack_start {
        #if SHOW_CODE_IN_STACK_TRACE {
            print_stack_trace_with_code(stack_start);
        } else {
            werr("\nStack trace:\n");
            print_stack_trace(stack_start);
        }
    } else {
        werr("(Stack trace unavailable; compile with options.stack_trace=true to see one.)\nExiting...\n");
    }

    werr("---------------------------------------------------------\n");

    __runtime_support_disable_stack_trace = true;

    ////////////////////////////////////////////////////////////
    // @note Modified copy of Debug.interactive_assert().

    // If the user clicks the abort button then we'll immediate call xexit and this return value isn't used for anything.

    // See if we have ignored this error before.
    found := table_find(*ignored_asserts, loc);
    if found return false; // This error is ignored.

    // Otherwise display an error dialog.
    response := show_assert_dialog(loc, message);
    if response == {
        case .IGNORE;
            werr("User wants to ignore...\n");
            table_add(*ignored_asserts, loc, true);

        case .DEBUG;
            werr("User wants to break/crash dump...\n");
            // Break into the debugger if attached, otherwise invokes the creation of a minidump if crash handlers are enabled.
            // @incomplete Email crash dump in release build.  :EmailOrUploadCrashDump
            return true;

        case .ABORT;
            werr("User wants to abort...\n");
            xexit(xx Debug.Exit_Code.Assert);
    }

    return false;
}

Assert_Dialog_Response :: enum {
    IGNORE;
    DEBUG;
    ABORT;
}

// @not Modified copy of Debug.show_assert_dialog().
show_assert_dialog :: (loc: Source_Code_Location, message: string) -> Assert_Dialog_Response {
    text := tprint ("Assert Failed: %\n\nAt: %:%:%\n\nABORT -> Exit process\nRETRY -> Debug break or generate crash dump\nIGNORE -> Continue and ignore this assert", message, loc.fully_pathed_filename, loc.line_number, loc.character_number);

    #if OS == .WINDOWS {
        // Flush message queue to ensure assert dialog is displayed next.
        msg: MSG;
        while PeekMessageW(*msg, null, 0, 0, PM_REMOVE) {
            TranslateMessage(*msg);
            DispatchMessageW(*msg);
        }

        action := MessageBoxW(null, utf8_to_wide(text,, temp), utf8_to_wide("Assert Failed",, temp), MB_ABORTRETRYIGNORE | MB_ICONERROR | MB_TOPMOST);
        if action == {
            case IDRETRY;  return .DEBUG;
            case IDIGNORE; return .IGNORE;
            case IDABORT;  return .ABORT;
        }
    }

    #if OS == .LINUX {
        X11 :: #import "X11";
        action := X11.x_message_box(X11.None, text, "%", .ST_ABORT_RETRY_IGNORE, "Assert Failed");
        if action == {
            case .RETRY;  return .DEBUG;
            case .IGNORE; return .IGNORE;
            case .ABORT;  return .ABORT;
        }
    }

    #if OS == .PS5 {
        return .DEBUG;
    }

    // @Incomplete: Add OSX message box.
    // For OS_SWITCH, we just return .Abort.

    // Abort by default.
    return .ABORT;
}

// Crashes the process with a big CRASH message. Will display an error dialog giving the user a chance to generate a minidump.
crash :: (format_string := "", args: .. Any, loc := #caller_location, action_name := "CRASH") {
    werrs("\n!!!!!!!!!!!!!!!!!!!!!!!!! ", action_name, " !!!!!!!!!!!!!!!!!!!!!!!!!\n");

    #if DEVELOPER {
        write_error_loc(loc);

        stack_start := context.stack_trace;
        if stack_start {
            // Attempt to skip the top-level entry of the stack trace, which will be this procedure. :WalkBackStack
            if stack_start.next then stack_start = stack_start.next;

            if stack_start.info && stack_start.info.name {
                werrs("Proc: ", stack_start.info.name, "\n");
            }
        }
    }

    message: string;

    if format_string {
        message = tprint(format_string, ..args);
        if message[message.count-1] != "\n"
            then werrs("\n", message, "\n\n");
            else werrs("\n", message, "\n");
    } else {
        werr("\n");
    }

    #if DEVELOPER {
        if stack_start {
            #if SHOW_CODE_IN_STACK_TRACE {
                print_stack_trace_with_code(stack_start);
            } else {
                werr("\nStack trace:\n");
                print_stack_trace(stack_start);
            }
        } else {
            werr("(Stack trace unavailable; compile with options.stack_trace=true to see one.)\n");
        }

        __runtime_support_disable_stack_trace = true;

        // See what the user wants to do.
        break_or_minidump := show_crash_dialog(loc, message, action_name);
        if !break_or_minidump {
            werr("User wants to abort...\n");
            // Might want to just do a hard TerminateProcess instead because
            // the app might unstable and trying to do a clean shutdown could
            // be problematic.:MaybeTerminateForStability
            xexit(1);
        } else werr("User wants to debug/crash...\n");
    }

    // Break into the debugger if attached, otherwise invokes the creation of a minidump if crash handlers are enabled.
    // @incomplete Email crash dump in release build.  :EmailOrUploadCrashDump
    debug_break();
    xexit(1); // Need this in case we start to debug and they continue execution. :MaybeTerminateForStability
} @PrintLike

// Set in main like so:
//   Debug.crash_handler = mc_crash_handler;
//
// @incomplete Email crash dump in release build.  :EmailOrUploadCrashDump
mc_crash_handler :: (stack_trace: [] string) {
    //#if DEVELOPER {
        if !__runtime_support_disable_stack_trace {
            // This was a crash that wasn't instigated by our assert, crash, etc routines so we need to
            // print the stack trace. We are likely here because of an exception crash so we don't want
            // to do anything fancy like allocate memory or log to a file.
            werr("\nStack trace:\n");
            for stack_trace {
                werrs("  ", it, "\n");
            }
        }
   // }
}

// @not Modified copy of Debug.show_assert_dialog().
show_crash_dialog :: (loc: Source_Code_Location, message: string, action_name: string) -> break_or_minidump: bool {
    text := tprint("%: %\n\nAt: %:%:%\n\nBreak into debugger/create minidump if no debugger attached?", action_name, message, loc.fully_pathed_filename, loc.line_number, loc.character_number);

    #if OS == .WINDOWS {
        // Flush message queue to ensure assert dialog is displayed next.
        msg: MSG;
        while PeekMessageW(*msg, null, 0, 0, PM_REMOVE) {
            TranslateMessage(*msg);
            DispatchMessageW(*msg);
        }

        action := MessageBoxW(null, utf8_to_wide(text,, temp), utf8_to_wide(action_name,, temp), MB_YESNO | MB_ICONERROR | MB_TOPMOST);
        return action == IDYES;
    }

    #if OS == .LINUX {
        X11 :: #import "X11";
        action := X11.x_message_box(X11.None, text, "%", .ST_YES_NO, action_name);
        return action == .YES;
    }

    #if OS == .PS5 {
        return true;
    }

    // @Incomplete: Add OSX message box.
    // For OS_SWITCH, we just return .Abort.

    // Crash by default.
    return true;
}

// Note: if the function fails to display anonymous procedure, check the code of runtime_support_assertion_failed in Jai.
//
// @important: It's recommended that you don't call this when handling an exception crash. This proc allocates memory and
// it might not work correctly due to the app being in an unstable state. In this situation just use print_stack_trace
// from the Basic module.
//
// Modified version from Arnaud Valensi https://gist.github.com/ArnaudValensi/9f0077bad262b96408e3dae47866f82d
print_stack_trace_with_code :: (node: *Stack_Trace_Node, to_standard_error := true) {
    set_console_color :: inline (builder: *String_Builder, color: Console_Color) {
        print(builder, "\e[%m", cast(int) color);
    }

    reset_console_color :: inline (builder: *String_Builder) {
        append(builder, "\e[0m");
    }

    indent :: inline (builder: *String_Builder, size: int) {
        for 1..size append(builder, " ");
    }

    print_line_with_context :: (builder: *String_Builder, file: string, line: int, padding_size: int, context_size := 3) {
        file_contents, success := File.read_entire_file(file);
        if !success return;

        lines := split(file_contents, "\n");
        focused_line := line - 1;
        start := max(focused_line - context_size, 0);
        end   := min(lines.count - 1, focused_line + context_size);

        for current_line: start..end {
            indent(builder, padding_size);

            if current_line == focused_line then set_console_color(builder, .HI_GREEN);

            print(builder, "% ", formatInt(current_line + 1, minimum_digits=padding_size, padding=" "));

            if current_line == focused_line
                then append(builder, "> ");
                else append(builder, "| ");

            print(builder, "%\n", lines[current_line]);

            if current_line == focused_line then reset_console_color(builder);
        }
    }

    depth_pad := ifx node.call_depth then node.call_depth - 1 else 0;
    stack_item_padding_size := tprint("%", depth_pad).count;

    builder: String_Builder;
    builder.allocator = temp;

    count: s32;

    while node {
        if node.info {
            function := node.info.name;
            file := node.info.location.fully_pathed_filename;
            line := node.line_number;

            print(*builder, "%: ", formatInt(count, minimum_digits=stack_item_padding_size, padding=" "));

            set_console_color(*builder, .HI_YELLOW);
            append(*builder, function);
            reset_console_color(*builder);
            append(*builder, "\n");

            indent(*builder, stack_item_padding_size + 2);
            print(*builder, "at %:%\n", file, line);

            print_line_with_context(*builder, file, line, stack_item_padding_size + 4);
        }

        node = node.next;
        count += 1;
    }

    write_strings(builder_to_string(*builder,, temp), "\n", to_standard_error=to_standard_error);
}

// Useful for finding allocation calls in a library. Just push this allocator
// at startup and it'll force crashes when used. You can then think about how
// you want to handle allocations, e.g. use default allocator, use an arena,
// etc.
//
// Another option if you're looking for leaks is to recompile your program with
// Memory_Debugger and it will tell you where all the leaks are. Or you can get
// a live visualization of the heap while it's running. If there is a problem
// you will see it.
make_assert_allocator :: () -> Allocator { return Allocator.{assert_allocator_proc, null}; }

assert_allocator_proc :: (mode: Allocator_Mode, requested_size: s64, old_size: s64, old_memory: *void, allocator_data: *void) -> *void {
    if #complete mode == {
        case .STARTUP;       #through;
        case .SHUTDOWN;      #through;
        case .THREAD_START;  #through;
        case .THREAD_STOP;   #through;
        case .CREATE_HEAP;   #through;
        case .DESTROY_HEAP;  #through;
        case .IS_THIS_YOURS; #through;
        case .CAPS;
            return null;
        case .FREE;          #through;
        case .RESIZE;        #through;
        case .ALLOCATE;
            print("\e[%m\n--------------------------------------------------\nUsed assert_allocator_proc\n\e[0m", cast(int) Console_Color.RED);
            if context.stack_trace {
                print("\n");
                print_stack_trace(context.stack_trace);
            }
            else {
                print("\e[%mNo stack trace available. Compile with options.stack_trace=true to see one.\n\e[0m", cast(int) Console_Color.RED);
            }
            xexit(1);
            return null;
    }
}

///////////////////////////////////////////////////////////////////////////////////////
// # LOGGING & PRINTING
///////////////////////////////////////////////////////////////////////////////////////

format_os_error :: #bake_arguments formatInt(base=16);

// @improve write my own console logger that changes the color of the text. This can then replace the
// usage of print_error since log_error will output red text. Look at 350_logging.jai and
// runtime_support_default_logger (make sure to also have thread safety).
color_print :: (color: Console_Color, format_string: string, args: .. Any) { // thread-safe
    // We're writing the color code instead of using Print_Color because that API doesn't do a single
    // print call so it's not safe to use with threads that are outputting to the console; can easily
    // end up coloring lines that shouldn't be colored!
    s := format_string;
    start_count := s.count;
    while ends_with(s, "\n") s.count -= 1;

    end_newline_count := start_count - s.count;
    end_newlines := ifx end_newline_count then fast_string(s, s.count, end_newline_count); // We aren't adding a newline if one wasn't provided.

    print(tprint("\e[%m%\e[0m%", cast(int) color, tprint(s, ..args), end_newlines)); // @incomplete log this instead?
} @PrintLike

print_error :: #bake_arguments color_print(color=.RED);
print_warn  :: #bake_arguments color_print(color=.YELLOW);

log_warn :: (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null) {
    new_flags := flags | .WARNING;
    log(format_string, ..args, loc, new_flags, user_flags, section);
} @PrintLike

#if DEVELOPER {
    dlog :: inline (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null) {
        log(format_string, ..args, loc, flags, user_flags, section);
    } @PrintLike

    dlog_warn :: inline (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null) {
        log_warn(format_string, ..args, loc, flags, user_flags, section);
    } @PrintLike

    dlog_error :: inline (format_string: string, args: ..Any, loc := #caller_location, flags := Log_Flags.NONE, user_flags: u32 = 0, section: *Log_Section = null) {
        log_error(format_string, ..args, loc, flags, user_flags, section);
    } @PrintLike

    dprint :: inline (format_string: string, args: ..Any) {
        print(format_string, ..args);
    } @PrintLike

    dcolor_print :: inline (color: Console_Color, format_string: string, args: ..Any) {
        color_print(color, format_string, ..args);
    } @PrintLike

    dprint_error :: inline (format_string: string, args: ..Any) {
        print_error(format_string, ..args);
    } @PrintLike

    dprint_warn :: inline (format_string: string, args: ..Any) {
        print_warn(format_string, ..args);
    } @PrintLike
}
else {
    dlog         :: (#discard format_string: string, #discard args: ..Any, #discard loc := #caller_location, #discard flags := Log_Flags.NONE, #discard user_flags: u32 = 0, #discard section: *Log_Section = null) #expand {}
    dlog_warn    :: (#discard format_string: string, #discard args: ..Any, #discard loc := #caller_location, #discard flags := Log_Flags.NONE, #discard user_flags: u32 = 0, #discard section: *Log_Section = null) #expand {}
    dlog_error   :: (#discard format_string: string, #discard args: ..Any, #discard loc := #caller_location, #discard flags := Log_Flags.NONE, #discard user_flags: u32 = 0, #discard section: *Log_Section = null) #expand {}
    dprint       :: (#discard format_string: string, #discard args: ..Any) #expand {}
    dcolor_print :: (#discard color: Console_Color,  #discard format_string: string, #discard args: ..Any) #expand {}
    dprint_error :: (#discard format_string: string, #discard args: ..Any) #expand {}
    dprint_warn  :: (#discard format_string: string, #discard args: ..Any) #expand {}
}

// Do we need this or can the user just capture print output in the log files?
log_struct :: (value: Any) {
    struct_printer_map: Table(*void, *void);
    defer table_reset(*struct_printer_map);
    ctx := context;
    ctx.print_style.struct_printer        = struct_printer;
    ctx.print_style.struct_printer_data   = *struct_printer_map;
    ctx.print_style.default_format_struct = FormatStruct.{ use_long_form_if_more_than_this_many_members=-1, use_newlines_if_long_form=true };
    push_context ctx {
       log("%\n", value);
    }
}

print_struct :: (value: Any) {
    struct_printer_map: Table(*void, *void);
    defer table_reset(*struct_printer_map);
    ctx := context;
    ctx.print_style.struct_printer        = struct_printer;
    ctx.print_style.struct_printer_data   = *struct_printer_map;
    ctx.print_style.default_format_struct = FormatStruct.{ use_long_form_if_more_than_this_many_members=-1, use_newlines_if_long_form=true };
    push_context ctx {
       print("%\n", value);
    }
}

// @incomplete loop over feature flags at compile time and save the max enum name length as a constant. Can use that for padding.
log_cpu_info :: (cpu_info: Cpu_X86) {
    log("CPU Info:");
    log("  Vendor: %", cpu_info.vendor);
    log("  Processor: %", "@Incomplete");
    log("  Features:");
    for name, value: enum_iterator(x86_Feature_Flag) {
        // @incomplete add padding
        log("    % %", ifx check_feature(cpu_info.feature_leaves, value) then "[*]" else "[ ]", name);
    }
}

// Uses temp memory!
log_temp_storage_use :: inline () {
    log("Temp storage size: %, occupied: %, highest water mark: %\n",
        context.temporary_storage.size,
        context.temporary_storage.total_bytes_occupied,
        context.temporary_storage.high_water_mark);
}

print_temp_storage_use :: inline () {
    print("Temp storage size: %, occupied: %, highest water mark: %\n",
          context.temporary_storage.size,
          context.temporary_storage.total_bytes_occupied,
          context.temporary_storage.high_water_mark);
}

// Single and double digit float formatting. Good for printing memory sizes.
fmt1 :: (value: f64) -> FormatFloat #expand { return FormatFloat.{value=value, trailing_width=1, zero_removal=.NO}; }
fmt2 :: (value: f64) -> FormatFloat #expand { return FormatFloat.{value=value, trailing_width=2, zero_removal=.NO}; }

///////////////////////////////////////////////////////////////////////////////////////
// # ARRAYS
///////////////////////////////////////////////////////////////////////////////////////

// Clears everything to zero. If you want to clear an AoS to the struct default then use clear_aos().
// Can also use clear().
//
// @note For resizable arrays use array_reset().
clear_array :: (array: [] $T) {
    memset(array.data, 0, array.count * size_of(type_of(array[0])));
}

clear_array :: (array: [] $T, value: T) {
    for 0..array.count-1 {
        array[it] = value;
    }
}

clear_aos :: (array: [] $T) {
    for * array it.* = .{};
}

resizable_array :: ($T: Type, capacity := 8) -> [..] T {
    result: [..] T;
    array_reserve(*result, capacity);
    return result;
}

// Thanks to kujuku for this.
// Use like so:
//   for x: efficient_remove(*things) {
//     if thing_is_dead(x) {
//       remove;
//     }
//   }
efficient_remove :: (captured: *[] $T) -> Efficient_Remove(T) {
    return Efficient_Remove(T).{captured};
}

Efficient_Remove :: struct (T: Type) {
    captured: *[] T;
}

for_expansion :: (wrapper: Efficient_Remove($T), body: Code, flags: For_Flags) #expand {
    // You can't efficiently remove in reverse as fas as I can tell unless you manually reverse first.
    #assert !(flags & .REVERSE);

    insert_index := 0;
    check_index  := 0;

    defer {
        // Handle breaking out of loop.
        while (insert_index != check_index) && (check_index < wrapper.captured.count) {
            wrapper.captured.*[insert_index] = wrapper.captured.*[check_index];
            insert_index += 1;
            check_index  += 1;
        }
        wrapper.captured.count -= check_index - insert_index;
    };

    while check_index < wrapper.captured.count {
        `it_index := check_index;

        #if flags & .POINTER {
            `it := *wrapper.captured.*[check_index];
        } else {
            `it := wrapper.captured.*[check_index];
        }

        should_keep := true;
        defer if should_keep {
            if insert_index != check_index {
                wrapper.captured.*[insert_index] = wrapper.captured.*[check_index];
            }
            insert_index += 1;
            check_index  += 1;
        }
        #insert(remove={check_index += 1; should_keep = false;}) body;
    }
}

//
//


// Lambda version of array_find from Basic/Array.jai, e.g.
//
//   thing, index := array_find(array_of_things, x => x.id, "foo");
//
// Can also pass a function instead of using a lambda.
array_find :: (array: [] $T, f: (T) -> $R, value: R) -> T, s64 {
    for array if f(it) == value return it, it_index;
    return default_of(T), -1;  // Not found.
}

array_contains :: (array: [] $T, item: T) -> bool, index: s64 {
    for array {
        if it == item then return true, it_index;
    }
    return false, -1;
}

// Macro version that lets you use local variables, e.g.
//   array_contains_code(array, #code (it == `my_local_var));
//
// Or you can create a reusable filter, e.g:
//   test :: #code (it.id == `my_local_var);
//   array_contains_code(array, test);
//
// @note: If I drop the _code part of the name then the compiler always uses this polymorph even when the #code directive isn't used.
array_contains_code :: (array: [] $T, code: Code) -> bool #expand {
    for array {
        if (#insert,scope() code) return true;
    }
    return false;
}

// Returns a new array with elements that have been modifed by the supplied function.
// Can use with a lambda or pass a proc, e.g.
//
//   new_arr := map(array, x => x.id * 2);
//
//   mult :: (x: Blah) -> int { return x.id * 2; }
//   new_arr := map(array, mult);
//
map :: (array: [] $T, f: (T) -> $R) -> [..] R {
    result: [..] R;
    for array {
        array_add(*result, f(it));
    }
    return result;
}

// Macro version of map. It requires you to specify what the code's result type is, e.g.
//
//   new_arr := map_code(array, int, #code (it.id *= `my_local_var));
//
// Or you can create a reusable modifier, e.g:
//   mult :: #code (it.id * `my_local_var);
//   new_arr := map_code(array, type_of(my_local_var), mult);
//
// @note: If I drop the _code part of the name then the compiler always uses this polymorph even when the #code directive isn't used.
map_code :: (array: [] $T, $R: Type, code: Code) -> [..] R #expand {
    result: [..] R;
    for array {
        x := #insert,scope() code;
        array_add(*result, x);
    }
    return result;
}

// Returns a new array containing items from array that passed the filter test.
// Can use with a lambda or pass a proc, e.g.
//
//   new_arr := filter(array, x => x.id == 2);
//
//   test :: (x: Blah) -> bool { return x.id == 2; }
//   new_arr := filter(array, test);
//
filter :: (array: [] $T, f: (T) -> bool) -> [..] T {
    result: [..] T;
    for array {
        if f(it) array_add(*result, it);
    }
    return result;
}

// Macro version of filter that lets you use local variables, e.g.
//   new_arr := filter_code(array, #code (it.something == `my_local_var));
//
// Or you can create a reusable filter, e.g:
//   test :: #code (it.id == `my_local_var);
//   new_arr := filter_code(array, test);
//
// @note: If I drop the _code part of the name then the compiler always uses this polymorph even when the #code directive isn't used.
filter_code :: (array: [] $T, code: Code) -> [..] T #expand {
    result: [..] T;
    for array {
        if (#insert,scope() code) array_add(*result, it);
    }
    return result;
}

// Pointer version of filter. The result stores pointers to the array elements
// allowing you to modify them. Just be mindful that if the array being
// filtered is dynamic and it gets resized, the returned array will contain
// invalid pointers. So in otherwords, don't keep the result around unless
// you're filtering a fixed-size array.
filter :: (array: *[] $T, f: (T) -> bool) -> [..] *T {
    result: [..] *T;
    for array.* {
        if f(it) array_add(*result, *it);
    }
    return result;
}

// Macro version of the pointer filter. Allows you to use local variables.
filter_code :: (array: *[] $T, code: Code) -> [..] *T #expand {
    result: [..] *T;
    for array.* {
        if (#insert,scope() code) array_add(*result, *it);
    }
    return result;
}

// In the range [0, count-1].
random_choice :: inline (state: *Random_State, count: u64) -> u64 { return random_get(state) % count; }
random_choice :: inline (state: *Random_State, array: [] $T) -> u64 {
    if array.count < 2 return 0;
    return random_choice(state, cast(u64) array.count);
}

// From Thread/thread_group.jai
shuffle :: (state: *Random_State, array: [] $T) {
    // We could do something more statistically correct here, but it probably requires more storage
    // (2 arrays?) so I am being lazybones for now.
    // - JBlow

    if array.count < 2 return;

    for i: 0..array.count-1 {
        j := random_choice(state, array);
        swap(*array[i], *array[j]);
    }
}


///////////////////////////////////////////////////////////////////////////////////////
// # STRINGS
///////////////////////////////////////////////////////////////////////////////////////

// From https://github.com/SogoCZE/Jails/blob/main/shared/binary_serialization.jai
// Can use like so:
//
// proc :: () -> string {
//      quick_string_builder();
//      a("some type");
//      p("give me % apples", 69);
//      return builder_to_string(b, do_reset=false,, temp); // We reset for you.
// }
//
quick_string_builder :: () #expand {
    `_builder: String_Builder;
    _builder.allocator = temp;
    // This defer is not needed if you always call builder_to_string but I guess it doesn't hurt in case you don't do that...
    `defer reset(*_builder);

    `b := *_builder;

    `p :: (format_string : string, args: ..Any) #expand {
        print(*_builder, format_string, ..args);
    } @PrintLike

    `a :: (the_string : string) #expand {
        append(*_builder, the_string);
    }
}

// Copy pasta of slice() from modules/String but without the safety checks.
fast_string :: inline (s: string, index: s64, count: s64) -> string {
    c := string.{count, s.data + index};
    return c;
}

fast_string :: inline (s: *u8, index: s64, count: s64) -> string {
    c := string.{count, s + index};
    return c;
}

free_string :: (s: *string) {
    assert(s != null);
    free(s.data);
    s.data  = null;
    s.count = 0;
}

// u8 (#char) to string.
// Modified version of valigo's code: https://discord.com/channels/661732390355337246/784843664651190273/1233342551185035285
to_string :: inline (c: u8) -> string {
    DOUBLE_QUOTE :: #string DONE
    "
    DONE
    VERTICAL_TAB :: #string DONE
    
    DONE

    FORM_FEED :: #string DONE
    
    DONE

    Char_Table :: string.[
        // 0-8 non-printable
        "<NULL>", "<SOH>", "<STX>", "<ETX>", "<EOT>", "<ENQ>", "<ACK>", "<BEL>", "<BS>",
        "\t", "\n",
        // 11 is vertical tab (\v), 12 is form feed (\f)
        // but Jai doesn't know their shorthands so do the #string
        VERTICAL_TAB, FORM_FEED,
        "\r",
        // 14-31 non-printable
        "<SO>", "<SI>", "<DLE>", "<DC1>", "<DC2>", "<DC3>", "<DC4>", "<NAK>", "<SYN>", "<ETB>", "<CAN>", "<EM>", "<SUB>", "<ESC>", "<FS>", "<GS>", "<RS>", "<US>",
        " ", "!", DOUBLE_QUOTE, "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?",
        "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
        "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_",
        "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
        "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~",
    ];

    if c > 126 return cast(string) u8.[c];
    return Char_Table[c];
}

// Expects the serialized form of an Apollo_Time value, which is an s128, e.g. "{LOW_U64, HIGH_S64}"
string_to_apollo :: (s: string) -> success: bool, Apollo_Time {
    if (s[0] != "{") || (s[s.count-1] != "}") {
        log_error("Invalid Apollo Time value: '%'", s);
        return false, APOLLO_TIME_INVALID;
    }

    comma_index := find_index_from_left(s, ",");
    if comma_index == -1 {
        log_error("Invalid Apollo Time value: '%'", s);
        return false, APOLLO_TIME_INVALID;
    }

    low_s  := fast_string(s, 1, comma_index-1);
    high_s := fast_string(s, comma_index+2, s.count - (comma_index+3));

    low, ok   := string_to_int(low_s,  T=u64);
    high, ok2 := string_to_int(high_s, T=s64);

    if !ok || !ok2 {
        log_error("Invalid Apollo Time value: '%'", s);
        return false, APOLLO_TIME_INVALID;
    }

    result := Apollo_Time.{low, high};

    return true, result;
}

// Copy pasta of find_index_from_left from modules/String but with the nocase test.
// Added this because of the comment above index_of_string_nocase()
find_index_from_left_nocase :: (s: string, substring: string, start_index := 0) -> s64 {
    if !substring return -1;

    // This is SO SLOW! @Cleanup.
    for start_index..s.count-substring.count {
        t := slice(s, it, substring.count);
        if equal_nocase(t, substring) return it;
    }

    return -1;
}

// Trim any \r or \n from the end of the input. If you want to try line endings
// and spaces, then use trim_right(s); from the string module.
trim_line_endings :: inline (s: string) -> string {
    result := trim_right(s, "\r\n");
    return result;
}

trim_line_endings :: inline (s: *string) {
    s.* = trim_right(s.*, "\r\n");
}

// Loop over the lines of a string.
// Usage:
//
// for :lines_of msg {
//    print("Line %: \"%\" has count %\n", it_index, it, it.count);
//}
lines_of :: (s: *string, body: Code, flags: For_Flags) #expand {
    #assert !(flags & .REVERSE);//, "This iterator does not support reverse iteration!";
    remaining := s.*;
    line_number := 1;
    while remaining.count > 0 {
        line := remaining;
        line_end_idx := find_index_from_left(line, "\n");
        if line_end_idx >= 0 {
            advance(*remaining, line_end_idx + 1);
            line.count = line_end_idx;
            if line && line[line.count - 1] == "\r" {
                line.count -= 1;
            }
        }
        else {
            remaining.count = 0;
        }
        `it := line;
        `it_index := line_number;
        line_number += 1;
        #insert(remove=#assert(false)) body;
    }
}

// Console input. Only writes buffer.count worth of characters. Usage example:
//
//   buffer := talloc_string(64);
//   ok, input := read_line_from_console(buffer);
//
read_line_from_console :: (buffer: string) -> success: bool, string {
    result: bool;

    // Alternative way using ReadConsoleA: https://github.com/Jai-Community/Jai-Community-Library/wiki/Snippets-and--Benchmarks#blocking-console-input
    // which is better?

    // @Incomplete: Jai doesn't have an abstraction for reading from stdin yet...
    #if OS == .WINDOWS {
        handle := GetStdHandle(STD_INPUT_HANDLE);
        bytes_read: u32;
        result = xx ReadFile(handle, buffer.data, cast(u32) buffer.count, *bytes_read, null);
    }
    else {
        bytes_read := read(STDIN_FILENO, buffer.data, cast(u64) buffer.count);
        if bytes_read < 0 then result = false;
    }

    input: string = ---;
    if bytes_read  {
        input.data = buffer.data;
        input.count = bytes_read;
        input = trim_line_endings(input);
    } else {
        input = "";
    }

    return result, input;
}

plural :: inline (x: int) -> string {
    return ifx x != 1 "s";
}

repeat :: (s: string, times: int) -> string {
    if (!times || s == "") return "";
    if (times == 1) return copy_string(s);

    count := times * s.count;
    result := alloc_string(count);

    for i: 0..count-1 {
        memcpy(result.data + (i * s.count), s.data, s.count);
    }

    return result;
}

repeat_char :: (character: u8, count: s64) -> string {
    if !count return "";

    result := alloc_string(count);
    memset(result.data, character, count * size_of(u8));
    return result;
}

// Modified version of String.split
split_by_spaces :: (s: string, ignore_empty_values: bool) -> [] string {
    result: [..] string;

    separator := " ";
    remainder := s;

    while remainder {
        found, left, right := split_from_left(remainder, separator);
        if found {
            if left || !ignore_empty_values {
                array_add(*result, left);
            }
        } else {
            array_add(*result, remainder);
            break;
        }
        remainder = right;
    }

    // We want 'split' to return an unambiguous result (was there a match at
    // the end or not?), and to be the inverse of 'join'. For this to happen,
    // if there was a match at the very end, we just add an empty string. Maybe
    // there is a more elegant way to structure the loop to make this happen.
    if !remainder && !ignore_empty_values  array_add(*result, "");

    return result;
}

// Similar to string module's slice, except it works with indices and supports
// negative values. This is exactly like the Javascript string slice().
//
// index_start is the index of the first character to include.
// index_end is the index of the first character to exclude.
//
// if index_start is negative, then truncation moves right-to-left, e.g.
// truncate("mike", -3) == "ike"
//
// Can combine with padding to do things like print a credit card number
// with only the last 4 digits being revealed:
//
//    cc := "2034399002125581";
//    last_4 := truncate(cc, -4);
//    masked := left_pad(last_4, cc.count, "*");
//
truncate :: (s: string, index_start: int, index_end: int) -> string {
    if index_start >= s.count  return "";
    if index_end > s.count index_end = s.count;

    if index_start < 0 then index_start = max(0, s.count - (-index_start));
    if index_end   < 0 then index_end   = max(0, s.count - (-index_end));

    c: string = ---;
    c.data = s.data + index_start;
    c.count = max(0, index_end - index_start);

    return c;
}

truncate :: (s: $T, index_start: int) -> string { return truncate(s, index_start, s.count); }

// Returns a new string. If total_length <= source count then a copy of the
// source string is returned, otherwise the string is padded on the left by
// pad_char until the result string is of total_length size.
left_pad :: (source: $T/.[string, u8], total_length: int, pad_char: u8 = " ") -> string {
    #if T == string
        then str := source;
        else str := tprint("%", source);

    if total_length <= str.count then return copy_string(str);

    result := alloc_string(total_length);
    pad_count := max(0, result.count - str.count);
    memset(result.data, pad_char, pad_count * size_of(u8));
    memcpy(result.data + pad_count, str.data, str.count);

    return result;
}

// Returns a new string. If total_length <= source length then a copy of the
// source string is returned, otherwise the string is padded on the right by
// pad_char until the result string is of total_length size.
right_pad :: (source: $T/.[string, u8], total_length: int, pad_char: u8 = " ") -> string {
    #if T == string
        then str := source;
        else str := tprint("%", source);

    if total_length <= str.count then return copy_string(str);

    result := alloc_string(total_length);
    pad_count := max(0, result.count - str.count);
    memcpy(result.data, str.data, str.count);
    memset(result.data + str.count, pad_char, pad_count * size_of(u8));

    return result;
}

// Can be used to print the name of any procedure.
//
// e.g. Current procedure
//
//   print("name: %\n", get_proc_name(#this));
//
// e.g. procs that are parameters to other procs, e.g.
//
//   foo :: (f: (int) -> int) {
//       print("name: %\n", get_proc_name(f));
//   }
//
//   bar :: (x: int) -> int { return x; }
//
//   foo(bar);  -> prints "bar"
//   @note If we were to just use #procedure_name(f) in foo() then the name would be "f".
//
get_proc_name :: ($c: Code) -> string #expand {
    return #procedure_name(#insert c);
}

// Needs to be used with #run, e.g. log("name %", #run get_identifier_name(main));
get_identifier_name :: ($c: Code) -> string #compile_time {
    node := compiler_get_nodes(c);
    if node.kind != .IDENT {
        compiler_report("Not an identifier.", make_location(node));
        return "";
    }
    ident := node.(*Code_Ident);
    return ident.name;
}

calendar_to_log_name_string :: (ct: Calendar_Time) -> string /* temporary allocator */ {
    using ct;
    date_part :: #bake_arguments formatInt(minimum_digits = 2);
    timezone_name := ifx ct.time_zone == .UTC then "Z"; // @Incomplete: Maybe determine local time zone name or offset
    result := tprint("%-%-%_%-%-%0%", year, date_part(month_starting_at_0 + 1), date_part(day_of_month_starting_at_0 + 1), date_part(hour), date_part(minute), date_part(second), timezone_name);
    return result;
}

///////////////////////////////////////////////////////////////////////////////////////
// # FILES
///////////////////////////////////////////////////////////////////////////////////////


safe_string_for_filename :: (s: string) -> string { /* temporary string */
    // Based off Windows filename restrictions. I don't care to customize based on OS at this time.
    NOT_ALLOWED :: u8.["/", "\\", ":", "*", "?",  "\"", "<", ">", "|"];
    REPLACEMENT :: u8.[",", ",",  "-", ".", ".",  "'",  "(", ")", "-"];
    result := copy_temporary_string(s);
    for NOT_ALLOWED {
        // @speed what's faster, the simd find index approach or just looping over the string chars?
        start_index := 0;
        while true {
            index := find_index_from_left(s, it, start_index);
            if index == -1 then break;
            start_index = index + 1;
            result[index] = REPLACEMENT[it_index];
        }
    }
    return result;
}

file_or_directory_exists :: (path: string, $log_errors := false) -> exists: bool, is_dir: bool, success: bool /* temporary allocator */ #deprecated "Use file_or_directory_exists_new() now and note that is_dir is now is_file !!! (we will change the name back later.)" {
    #assert false;
}

// Some of this code is a copy pasta of file_exists() and other functions in modules/File/windows.
// This version has long path support, which was extracted from make_directory_helper().
file_or_directory_exists_new :: (path: string, $log_errors := false) -> success: bool, exists: bool, is_file: bool /* temporary allocator */ {
    #if OS == .WINDOWS {
        // -12 comes from it also needing to include the 8.3 form for file names.
        MAX_DIRECTORY_PATH :: MAX_PATH - 12;
        LONG_PATH_PREFIX :: "\\\\?\\";

        path_wide, success := utf8_to_wide(path,, temp);
        if !success {
            #if log_errors then log_error("In file_or_directory_exists_new(), failed to convert path from UTF8 to UTF16.\n");
            return false, false, false;
        }

        if !begins_with(path, LONG_PATH_PREFIX) {
            full_path_size := GetFullPathNameW(path_wide, 0, null, null); // returns the size in WCHARs _including_ the terminating 0.
            if !full_path_size {
                #if log_errors {
                    code, error := System.get_error_value_and_string();
                    log_error("GetFullPathNameW (without buffer) failed! OS Error 0x%: %", format_os_error(code), error);
                }
                return false, false, false;
            }

            if full_path_size > MAX_DIRECTORY_PATH {
                prefixed_full_path_size := full_path_size + LONG_PATH_PREFIX.count; // Size in WCHARs with the prefix.
                full_path_wide: *u16 = talloc(prefixed_full_path_size * 2);
                memcpy(full_path_wide, utf8_to_wide(LONG_PATH_PREFIX,, temp), LONG_PATH_PREFIX.count * 2); // @Speed: do this utf8_to_wide() only once, at compile time?
                real_full_path_size := GetFullPathNameW(path_wide, full_path_size, full_path_wide + LONG_PATH_PREFIX.count, null); // returns the size in WCHARs _not including_ the terminating 0. Converts to Windows backslashes, which is needed when working with long paths.c0e

                if !real_full_path_size {
                    #if log_errors {
                        code, error := System.get_error_value_and_string();
                        log_error("GetFullPathNameW (with buffer) failed! OS Error 0x%: %", format_os_error(code), error);
                    }
                    return false, false, false;
                }
                assert(real_full_path_size <= full_path_size - 1); // -1 because on success, it does NOT include the null character, but on failure it does. This used to be ==, but in some cases we get a shorter path... I guess the return value of GetFullPathNameW is inexact in some cases!

                path_wide = full_path_wide;
            }
        }

        attrib := GetFileAttributesW(path_wide);

        if attrib == INVALID_FILE_ATTRIBUTES return false, false, true;
        return true, true, (attrib & FILE_ATTRIBUTE_DIRECTORY) != FILE_ATTRIBUTE_DIRECTORY;
    }
    else {
        #assert false "Unsupported OS";
    }
}

log_path_existence_on_the_local_filesystem :: (path_str: string, message: string = "", show_hint_about_colored_text := true) { /* temporary allocator */
    // @fixme there is a bug with the path module not accounting for an absolute windows path in how_much_of_path_exists_on_the_local_filesystem.
    // Waiting for my patch to be merged; in the meantime check for path existence with file_or_directory_exists_new and then call this if it fails.
    // (my patch is in jai/bugs/my-patches-for-unfixed-bugs/fix-path-module-checking-for-path-existence; see local module change & the example code)

    path := FT.parse_path(path_str);
    _, how_much_exists := FT.how_much_of_path_exists_on_the_local_filesystem(path);

    partial_string := FT.path_to_string(path, how_much_exists);

    remainder: FT.Path;
    remainder.trailing_slash = path.trailing_slash;

    remainder_words := path.words;
    remainder_words.data += how_much_exists;
    remainder_words.count -= how_much_exists;

    remainder.words = remainder_words;
    remainder_string := FT.path_to_string(remainder);

    if message {
        print(message, to_standard_error=true); // Using print so that a newline isn't added to the end, like it is in log_error.
    }

    print_color("%",   partial_string,   color=.HI_GREEN, to_standard_error=true);
    print_color("%\n", remainder_string, color=.RED,      to_standard_error=true);

    if show_hint_about_colored_text {
        print("\n(If the above doesn't show color then the portion not found is \"%\")\n", remainder_string, to_standard_error=true);
    }
}

// Use this instead of is_absolute_path() from modules/String.
//
// Mostly a copy pasta of the one from the string module except I'm tweaking it
// to not look for a slash, since you don't always get one (e.g. MinGW turns
// /z/ or z:\\ into just 'z:'). Also checking for an alpha character at the
// start.
//
// @improve should this reduce the path?
is_an_absolute_path :: (path: string) -> bool, enum { NONE; UNIX; WINDOWS; } {
    if !path return false, .NONE;

    if path[0] == "/"  return true, .UNIX;
    if path[0] == "\\" return true, .UNIX;

    #if OS == .WINDOWS {
        if path.count >= 2 {
            if is_alpha(path[0]) && (path[1] == ":") return true, .WINDOWS; // Drive letter.
        }
    }

    return false, .NONE;
}

// Returns a path string that doesn't have any ../ parts because the final destination has been worked out.
get_reduced_path :: (path: string) -> string /* temporary allocator */ {
    reduced := FT.parse_path(path, reduce=true,, temp);
    result := FT.path_to_string(reduced,, temp);
    return result;
}

// Probably best with an absolute path?
verify_path_exists :: (path: string, short_name: string, $expected_kind: enum { NONE; FILE; DIR; } = .NONE) -> exists: bool, is_file: bool {
    success, exists, is_file := file_or_directory_exists_new(path);
    if !success {
        code, error := System.get_error_value_and_string();
        log_error("Failed to check if % path '%' exists! OS Error 0x%: %\n", short_name, path, format_os_error(code), error);
        return false, false;
    }

    if !exists {
        log_path_existence_on_the_local_filesystem(path, tprint("% path doesn't exist: ", short_name));
        return false, false;
    }

    #if expected_kind == .FILE {
        if !is_file {
            log_error("Expected % path '%' to be a file, but got a directory instead!\n", short_name, path);
            return false, false;
        }
    } else if expected_kind == .DIR {
        if is_file {
            log_error("Expected % path '%' to be a directory, but got a file instead!\n", short_name, path);
            return false, false;
        }
    }

    return true, is_file;
}

// If given a relative path then an absolute version is returned. Can be relative to the exe or the cwd.
get_absolute_path :: (path: string, $normalize_slashes := true, $use_cwd := false, $reduce_path := false) -> string, already_absolute: bool /* temporary allocator */ {
    push_allocator(temp);

    s: string = ---;
    #if reduce_path {
        s = FT.path_to_string(FT.parse_path(path, reduce=true));
    } else {
        s = copy_temporary_string(path);
    }

    #if normalize_slashes {
        #if OS == .WINDOWS path_overwrite_separators(s, "/");
    }
    while ends_with(s, "/") s.count -= 1;

    if is_an_absolute_path(s) {
        return s, true;
    }

    base_path: string = ---;
    // These are temp strings.
    #if use_cwd {
        base_path = get_working_directory();
        assert(base_path);
    } else {
        base_path = path_strip_filename(System.get_path_of_running_executable());
    }
    #if normalize_slashes {
        #if OS == .WINDOWS path_overwrite_separators(base_path, "/");
    }
    if ends_with(base_path, "/") base_path.count -= 1;

    result := tprint("%/%", base_path, s);
    if ends_with(result, "/") result.count -= 1; // We can get a trailing slash when s is an empty string.

    return result, false;
}

is_root_drive_path :: (path: string) -> bool {
    if !path return false;
    #if OS == .WINDOWS {
        result := (path.count <= 3) && (path[1] == ":"); // e.g. A: or A:/
    }
    else {
        #assert false "Unsupported OS"; // I'm lazy. Count slashes and error if 1 or 2 are found.
    }

    return result;
}

// Copy pasta of copy_file() from modules/File_Utilities with some tweaks.
// I'm allowing files to be overwritten. If overwrite_if_exists is false and a
// file already exists then this will fail. You can use GetLastError to check
// for the code ERROR_FILE_EXISTS 80 (0x50).
copy_file_with_overwriting :: (source: string, dest: string, overwrite_if_exists := false) -> bool  {
    #if OS == .WINDOWS {
        // @improve Add long path support!
        // @improve Add long path support!
        // @improve Add long path support!
        source_wstr := utf8_to_wide(source,, temp);
        dest_wstr   := utf8_to_wide(dest,, temp);

        fail_if_exists := !overwrite_if_exists;

        success := CopyFileW(source_wstr, dest_wstr, xx fail_if_exists);
        if success return true;
        return false;
    }
    else {
        #assert false "Unsupported OS";
    }
}
#if OS == .WINDOWS {
    // @improve Ask Jon to add this to Windows.jai
    ERROR_FILE_EXISTS :: 0x50;
}


// From Focus.
delete_directory_recursively :: (path: string) -> bool {
    // NOTE:
    // Ideally we'd want to use the standard library's delete_directory function, but on Windows
    // it uses the SHFileOperationW function, which can load a HELL OF A LOT of useless DLLs into
    // the process and cause an unnecessary slowdown. So we're doing it ourselves here.

    result := true;

    directory_visitor_func :: (info: *FT.File_Visit_Info, success_pointer: *bool) {
        if info.is_directory {
            assert(!info.is_symlink);
            FT.visit_files(info.full_name, recursive=false, success_pointer, directory_visitor_func, visit_files=true, visit_directories=true, visit_symlinks=true, follow_directory_symlinks=false);
            deleted := delete_empty_directory(info.full_name);
            if !deleted {
                code, error := System.get_error_value_and_string();
                log_error("Error while trying to delete \"%\"! OS Error 0x%: %", info.full_name, format_os_error(code), error);
                success_pointer.* = false;
            }

        }
        else {
            deleted := File.file_delete(info.full_name);
            if !deleted {
                code, error := System.get_error_value_and_string();
                log_error("Error while trying to delete \"%\"! OS Error 0x%: %", info.full_name, format_os_error(code), error);
                success_pointer.* = false;
            }
        }
    }

    FT.visit_files(path, recursive=false, *result, directory_visitor_func, visit_files=true, visit_directories=true, visit_symlinks=true, follow_directory_symlinks=false);

    if result {
        result = delete_empty_directory(path);
    }

    return result;
}

delete_empty_directory :: (path: string) -> bool {
    #if OS == .WINDOWS {
        result := RemoveDirectoryW(utf8_to_wide(path,, temp));
        return cast(bool) result;
    }
    else {
        POSIX :: #import "POSIX";
        result := POSIX._remove(temp_c_string(path));
        return result == 0;
    }
}

delete_old_files :: (directory_path: string, extension: string, keep_last: int, $log_deletions := false) {
    auto_release_temp();

    Visit_Data :: struct {
        extension: string;
        files: [..] struct { full_name: string; mod_time: Apollo_Time; };
        files.allocator = temp;
    }

    visitor :: (info: *FT.File_Visit_Info, user_data: *Visit_Data) {
        ext := path_extension(info.full_name);
        if ext == user_data.extension {
            array_add(*user_data.files, .{ copy_temporary_string(info.full_name), info.modification_time });
        }
    }

    visit_data := Visit_Data.{ extension=extension };
    FT.visit_files(directory_path, recursive=false, *visit_data, visitor, visit_directories=false, visit_symlinks=false);

    if visit_data.files.count > keep_last {
        quick_sort(visit_data.files, (a, b) => compare_apollo_times(a.mod_time, b.mod_time));

        delete_count := visit_data.files.count - keep_last;
        #if log_deletions log("Pruning % old % file%\n", delete_count, extension, plural(delete_count));

        for 0..delete_count-1 {
            ok := File.file_delete(visit_data.files[it].full_name);
            if ok {
                #if log_deletions log("Deleted '%'\n", visit_data.files[it].full_name);
            }
            else {
                code, error := System.get_error_value_and_string();
                log_error("Failed to delete % file #% with name \"%\"! OS Error 0x%: %", extension, it+1, visit_data.files[it].full_name, format_os_error(code), error);
            }
        }
    }
}

file_rename :: File.file_move;

///////////////////////////////////////////////////////////////////////////////////////
// # MATH
///////////////////////////////////////////////////////////////////////////////////////

is_pow2 :: inline (x: u32) -> bool {
    // Complement and compare; slightly faster than decrement and compare. Only use this with unsigned values.
    result := ((x & (~x + 1)) == x);
    return result;
}

floor :: inline (v: Vector2) -> Vector2 {
    return .{floor(v.x), floor(v.y)};
}

floor :: inline (v: Vector3) -> Vector3 {
    return .{floor(v.x), floor(v.y), floor(v.z)};
}

round :: inline (v: f32) -> f32 {
    return floor(v + 0.5);
}

round :: inline (v: Vector2) -> Vector2 {
    return .{floor(v.x + 0.5), floor(v.y + 0.5)};
}

round :: inline (v: Vector3) -> Vector3 {
    return .{floor(v.x + 0.5), floor(v.y + 0.5), floor(v.z + 0.5)};
}

/* @incomplete
eerp :: (a, b, t) -> something {
    // Good for zooming or anything that shouldn't be lerped  https://twitter.com/FreyaHolmer/status/1486714301540831234
    return a^(1-t) * b^t;
}
*/

move_toward :: (a_pointer: *float, target: float, dt: float, rate_up: float, rate_down: float = -1.0) {
    a := a_pointer.*;

    if a > target {
        if rate_down == -1 rate_down = rate_up;
        a -= dt * rate_down;
        if a < target  a = target;
        a_pointer.* = a;
    } else if a < target {
        a += dt * rate_up;
        if a > target  a = target;
        a_pointer.* = a;
    }
}

move_toward :: (a_pointer: *v2, target: v2, dt: float, rate_up: float, rate_down: float = -1.0) {
    a := a_pointer.*;

    dist := distance(a, target);
    if !dist return;

    if rate_down == -1.0 {
        rate_down = rate_up; // Use rate_up if rate_down is not provided.
    }

    rate_x := ifx a.x > target.x then rate_down else rate_up;
    rate_y := ifx a.y > target.y then rate_down else rate_up;

    move_dist_x := dt * rate_x;
    move_dist_y := dt * rate_y;

    // Clamp the move distance to not overshoot the target.
    if move_dist_x > abs(target.x - a.x) {
        move_dist_x = abs(target.x - a.x);
    }
    if move_dist_y > abs(target.y - a.y) {
        move_dist_y = abs(target.y - a.y);
    }

    direction := target - a;
    norm_dir := normalize(direction);

    a += norm_dir * .{move_dist_x, move_dist_y};
    a_pointer.* = a;
}

///////////////////////////////////////////////////////////////////////////////////////
// # METAPROGRAMMING
///////////////////////////////////////////////////////////////////////////////////////

// e.g. thing_that_takes_a_resizeable_array(default_of([..]int));
default_of :: ($T: Type) -> T #expand {
    t: T;
    return t;
}

// From the community wiki https://github.com/Jai-Community/Jai-Community-Library/wiki/Snippets-and--Benchmarks#macro---modify-require
// It lets you restrict a polymorphic function to a specific type.
ModifyRequire :: (t: Type, kind: Type_Info_Tag) #expand {
    `return (cast(*Type_Info) t).type == kind, tprint("T must be %", kind);
}

// Use this procedure in a #run to verify that an enum has the #specified directive.
// An example of when you would use this is when you're serializing an enum value and want to make sure
// that no one removes the specified directive (see enums how-to in jai docs for thoughts behind serialization).
//
// usage example:
//
//  Operating_Systems :: enum u16 #specified {
//      VMS      :: 1;
//      ATT_UNIX :: 2;
//      WINDOWS  :: 3;
//      GNU_SLASH_LINUX_OR_WHATEVER :: 4;
//  }
//  #run expect_specified(Operating_Systems);

expect_specified :: ($T: Type) #compile_time {
    info := type_info(T);
    assert(info.type == .ENUM);
    assert((info.enum_type_flags & .SPECIFIED) == .SPECIFIED, "Enum % is expected to have the #specified directive but it doesn't!", info.name);
}

// From shwa https://discord.com/channels/661732390355337246/784843664651190273/1167285494711857233
// Can use the align_of macro below to get compile-time alignment of primitive types and structs.
align_of :: (ti: *Type_Info) -> int #compile_time {
    if ti.type == {
        case .INTEGER;       return ti.runtime_size;
        case .FLOAT;         return ti.runtime_size;
        case .BOOL;          return ti.runtime_size;
        case .STRING;        return 8;
        case .POINTER;       return 8;
        case .PROCEDURE;     return 8;
        case .STRUCT; {
            dti := cast(*Type_Info_Struct) ti;
            m: int;
            for member: dti.members {
                m = max(m, align_of(member.type));
            }
            return m;
        }
        case .ARRAY; {
            dti := cast(*Type_Info_Array) ti;
            if dti.array_type == {
                case .FIXED;     return align_of(dti.element_type);
                case .VIEW;      return 8;
                case .RESIZABLE; return 8;
                case; assert(false);
            }
        }
        case .ANY;           return 8;
        case .ENUM;          return ti.runtime_size;
        case .TYPE;          return ti.runtime_size;
        case .VARIANT;       return align_of((cast(*Type_Info_Variant) ti).variant_of);
        case; assert(false, "%", ti.type);
    }
    assert(false);
    return -1;
}

align_of :: inline ($T: Type) -> int #compile_time {
    return align_of(type_info(T));
}

enum_count :: inline ($T: Type) -> s64 #modify ModifyRequire(T, .ENUM) {
    return type_info(T).values.count;
}

//
// Original enum iterator from Felix (mairibu) in the secret beta group: https://discord.com/channels/661732390355337246/784843664651190273/984059000523997234
//
// Usage example: see log_cpu_info() and /study/jai/enum_iteration.jai

// Enum for loop gives you the member name as a string and the member value as the enum type. Can get the s64 value by casting or using Enum_Iterator_s64.
Enum_Iterator :: struct(T: Type) #modify ModifyRequire(T, .ENUM) {}
enum_iterator :: ($T: Type) -> Enum_Iterator(T) { return Enum_Iterator(T).{}; }

// Enum for loop gives you the member name as a string and the member value as an s64.
Enum_Iterator_s64 :: struct(T: Type) #modify ModifyRequire(T, .ENUM) {}
enum_iterator_s64 :: ($T: Type) -> Enum_Iterator_s64(T) { return Enum_Iterator_s64(T).{}; }

// Enum for loop gives you the enum value as the enum type (can cast to s64 if required) and its index in the enum values array.
Enum_Value_Iterator :: struct(T: Type) #modify ModifyRequire(T, .ENUM) {}
enum_value_iterator :: ($T: Type) -> Enum_Value_Iterator(T) { return Enum_Value_Iterator(T).{}; }

// For enum iterator
for_expansion :: (iterator: *Enum_Iterator($T), body: Code, flags: For_Flags) #expand {
    info := type_info(iterator.T);
    #assert(flags & .POINTER == 0);
    for enum_name, index: info.names {
        enum_value := info.values[index];
        `it       := enum_name;
        `it_index := cast(iterator.T) enum_value;
        #insert body;
    }
}

for_expansion :: (iterator: *Enum_Iterator_s64($T), body: Code, flags: For_Flags) #expand {
    info := type_info(iterator.T);
    #assert(flags & .POINTER == 0);
    for enum_name, index: info.names {
        enum_value := info.values[index];
        `it       := enum_name;
        `it_index := enum_value;
        #insert body;
    }
}

for_expansion :: (iterator: *Enum_Value_Iterator($T), body: Code, flags: For_Flags) #expand {
    info := type_info(iterator.T);
    #assert(flags & .POINTER == 0);
    for value, index: info.values {
        `it       := cast(iterator.T) value;
        `it_index := index;
        #insert body;
    }
}

// Create a string array made up of the member names of an enum.
// e.g. NAMES :: #insert #run make_enum_name_array(My_Enum);
make_enum_name_array :: ($t: Type) -> string #compile_time #modify ModifyRequire(t, .ENUM) {
    builder: String_Builder;
    append(*builder, "string.[\n");
    for enum_iterator_s64(t) {
        print(*builder, "    \"%\",\n", it);
    }
    append(*builder, "];\n");
    return builder_to_string(*builder);
}

#scope_file

struct_printer :: (builder: *String_Builder, item: Any, userdata: *void) -> bool {
   if item.type.type == .POINTER {
      pt := cast(*Type_Info_Pointer)(item.type);
      pointed_to_item: Any;
      pointed_to_item.type = pt.pointer_to;
      assert(pointed_to_item.type != type_info(FormatStruct));
      pointed_to_item.value_pointer = cast(*void) (cast(*u64) item.value_pointer).*;
      if pointed_to_item.value_pointer {
         print_type_to_builder(builder, pointed_to_item.type);
         ptr := pointed_to_item.value_pointer;

         default := context.print_style.default_format_absolute_pointer;
         default.value = cast(u64) ptr;
         print(builder, " %", default);

         table := cast(*Table(*void, *void)) userdata;
         found, value := table_find(table, ptr);
         if !found {
            print(builder, " ");
            table_add(table, ptr, ptr);
            print_item_to_builder(builder, pointed_to_item);
         }

         return true;
      }
   }
   return false;
}

// Copied from Debug module.
hash_scl :: (loc : Source_Code_Location) -> u32 {
    h := sdbm_hash(loc.fully_pathed_filename.data, loc.fully_pathed_filename.count);
    h = sdbm_hash(*loc.line_number, size_of(type_of(loc.line_number)), h);
    h = sdbm_hash(*loc.character_number, size_of(type_of(loc.character_number)), h);
    return h;
}

// Copied from Debug module.
compare_scl :: (a: Source_Code_Location, b: Source_Code_Location) -> bool {
    return
        a.fully_pathed_filename == b.fully_pathed_filename &&   // @@ We may guarantee that these strings are unique so that only the pointers need to be compared.
        a.line_number == b.line_number &&
        a.character_number == b.character_number;
}

ignored_asserts : Table(Source_Code_Location, bool, hash_scl, compare_scl);

werr  :: inline (s : string)         #no_context { write_string  (s,   to_standard_error=true); };
werrs :: inline (s : ..string)       #no_context { write_strings (..s, to_standard_error=true); };
wnum  :: inline (n: s64, base := 10) #no_context { write_number  (n, base, to_standard_error=true); };

write_error_loc :: inline (loc: Source_Code_Location) #no_context {
    werrs("\nFile: ", loc.fully_pathed_filename, "\nLine: ");
    wnum(loc.line_number);
    werr("\n");
}

#import "Basic";
assert :: mc_assert;

#import "Compiler";
#import "Hash_Table";
#import "String";
#import "Machine_X64";
#import "Print_Color";
#import "Random";
#import "Sort";
#import "Hash";
#import "Process";

File   :: #import "File";
FT     :: #import "File_Utilities";
System :: #import "System";
Debug  :: #import "Debug";

#if OS == .WINDOWS {
    #import "Windows";
    #import "Windows_Utf8";
}

#if DEVELOPER {
    using,only(print_expression) PP :: #import "Program_Print";
}

