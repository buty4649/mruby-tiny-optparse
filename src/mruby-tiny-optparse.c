#include <mruby.h>
#include <mruby/presym.h>

void
mrb_mruby_tiny_optparse_gem_init(mrb_state* mrb)
{
    struct RClass *optparse = mrb_define_class_id(mrb, MRB_SYM(OptionParser), mrb->object_class);
    struct RClass *parse_error = mrb_define_class_under_id(mrb, optparse, MRB_SYM(ParseError), mrb->eStandardError_class);
    mrb_define_class_under_id(mrb, optparse, MRB_SYM(InvalidOption), parse_error);
    mrb_define_class_under_id(mrb, optparse, MRB_SYM(MissingArgument), parse_error);
    mrb_define_class_under_id(mrb, optparse, MRB_SYM(NeedlessArgument), parse_error);
}

void
mrb_mruby_tiny_optparse_gem_final(mrb_state* mrb)
{
}
