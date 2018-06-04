//          Copyright Jean Pierre Cimalando 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

#include <RtMidi.h>
#include <libguile.h>
#include <memory>
#include <string>
#include <vector>
#include <unistd.h>

static std::vector<const char *> args_to_argv(
    const std::vector<std::string> &args);

static RtMidiOut *ms_port = nullptr;
static std::vector<uint8_t> ms_writebuf;
static SCM ms_write(SCM msg);

///
int main(int argc, char *argv[])
{
  std::vector<std::string> scm_args;
  scm_args.push_back("midi-shell");
  scm_args.push_back("-q");

  std::string homedir = getenv("HOME");
  std::string rcfile = homedir + "/.midi-shell-rc";
  if (access(rcfile.c_str(), F_OK) == 0) {
    scm_args.push_back("-l");
    scm_args.push_back(rcfile);
  }

  scm_init_guile();

  struct ModuleContext {
    const std::vector<std::string> *scm_args;
    std::string lisp_home;
  } modcontext;

  modcontext.scm_args = &scm_args;
  modcontext.lisp_home = std::string(PREFIX) + "/share/midi-shell/lisp";

  if (access((modcontext.lisp_home + "/stdlib.scm").c_str(), F_OK) != 0) {
      fprintf(stderr, "Could not find lisp home at '%s'\n", modcontext.lisp_home.c_str());
      return 1;
  }

  scm_c_define_module("midi-shell", [](void *userdata) {
      ModuleContext &modcontext = *(ModuleContext *)userdata;
      scm_c_define_gsubr("ms:write", 1, 0, 0, (scm_t_subr)ms_write);
      scm_primitive_load(scm_from_utf8_string((modcontext.lisp_home + "/stdlib.scm").c_str()));
      scm_primitive_load(scm_from_utf8_string((modcontext.lisp_home + "/sysex.scm").c_str()));
      scm_primitive_load(scm_from_utf8_string((modcontext.lisp_home + "/xg.scm").c_str()));
    }, &modcontext);


  ///
  RtMidi::Api api = RtMidi::UNSPECIFIED;
  std::unique_ptr<RtMidiOut> port(new RtMidiOut(api, "MIDI Shell"));
  ::ms_port = port.get();
  port->openVirtualPort();

  ///
  ms_writebuf.reserve(8192);

  ///
  scm_c_use_module("midi-shell");
  scm_shell(scm_args.size(),
            (char **)args_to_argv(scm_args).data());

  return 0;
}

///
std::vector<const char *> args_to_argv(const std::vector<std::string> &args)
{
  size_t argc = args.size();
  std::vector<const char *> argv(argc);
  for (size_t i = 0; i < argc; ++i)
    argv[i] = args[i].c_str();
  argv.push_back(nullptr);
  return argv;
}

///
SCM ms_write(SCM msg)
{
  RtMidiOut &port = *ms_port;
  std::vector<uint8_t> &buf = ms_writebuf;
  size_t len = scm_to_size_t(scm_vector_length(msg));

  try {
    buf.resize(len);
  } catch (std::exception &ex) {
    SCM what = scm_from_utf8_string(ex.what());
    scm_error(scm_misc_error_key, "ms:write", "~A", scm_list_1(what), SCM_BOOL_F);
  }

  for (size_t i = 0; i < len; ++i)
    buf[i] = scm_to_uint8(scm_vector_ref(msg, scm_from_size_t(i)));

  try {
    port.sendMessage(&buf);
  } catch (std::exception &ex) {
    SCM what = scm_from_utf8_string(ex.what());
    scm_error(scm_misc_error_key, "ms:write", "~A", scm_list_1(what), SCM_BOOL_F);
  }

  return SCM_BOOL_T;
}
