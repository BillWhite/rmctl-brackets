PARTS=base_hook clamp_screw hexnut clamp_jaw clamp_screw_top
SOURCES=$(PARTS) hexnut
CLEANOBJS=$(patsubst %,%.d,$(SOURCES)) \
          $(patsubst %,%.stl,$(SOURCES)) \
          README.html

parts: $(patsubst %,%.stl,$(PARTS))

all: $(patsubst %,%.stl,$(SOURCES))

%.stl: %.scad
	openscad -o $@ $< -d $*.d

clean:
	rm -f $(CLEANOBJS)

-include base_hook.d
-include clamp_screw.d
-include hexnut.d
