PARTS=base_hook clamp_jaw
SOURCES=$(PARTS) hexnut
CLEANOBJS=$(patsubst %,.d/%.d,$(SOURCES)) \
          $(patsubst %,stl/%.stl,$(SOURCES)) \
          README.html
DIRS=.d stl

parts: $(DIRS) $(patsubst %,stl/%.stl,$(PARTS))

all: $(DIRS) $(patsubst %,stl/%.stl,$(SOURCES))

stl/%.stl: %.scad
	openscad -o $@ $< -d ./.d/$*.d

$(DIRS):
	mkdir .d stl

clean:
	rm -f $(CLEANOBJS)


-include .d/base_hook.d
-include .d/clamp_screw.d
-include .d/hexnut.d
