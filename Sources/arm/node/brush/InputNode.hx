package arm.node.brush;

import iron.math.Vec4;
import arm.ui.UISidebar;

@:keep
class InputNode extends LogicNode {

	var coords = new Vec4();

	var startX = 0.0;
	var startY = 0.0;

	// Brush ruler
	var lockBegin = false;
	var lockX = false;
	var lockY = false;
	var lockStartX = 0.0;
	var lockStartY = 0.0;

	public function new(tree: LogicTree) {
		super(tree);
		tree.notifyOnUpdate(function() {

			if (UISidebar.inst.splitView) {
				UISidebar.inst.viewIndex = iron.system.Input.getMouse().viewX > arm.App.w() / 2 ? 1 : 0;
			}

			UISidebar.inst.brushLazyRadius = inputs[0].get();
			UISidebar.inst.brushLazyStep = inputs[1].get();

			var lazyPaint = UISidebar.inst.brushLazyRadius > 0 && Operator.shortcut(Config.keymap.action_paint);

			var mouse = iron.system.Input.getMouse();
			var paintX = mouse.viewX / iron.App.w();
			var paintY = mouse.viewY / iron.App.h();
			if (mouse.started()) {
				startX = mouse.viewX / iron.App.w();
				startY = mouse.viewY / iron.App.h();
			}

			var pen = iron.system.Input.getPen();
			if (pen.down()) {
				paintX = pen.viewX / iron.App.w();
				paintY = pen.viewY / iron.App.h();
			}
			if (pen.started()) {
				startX = pen.viewX / iron.App.w();
				startY = pen.viewY / iron.App.h();
			}

			if (Operator.shortcut(Config.keymap.brush_ruler + "+" + Config.keymap.action_paint)) {
				if (lockX) paintX = startX;
				if (lockY) paintY = startY;
			}

			if (UISidebar.inst.brushLazyRadius > 0) {
				UISidebar.inst.brushLazyX = paintX;
				UISidebar.inst.brushLazyY = paintY;
			}
			if (!lazyPaint) {
				coords.x = paintX;
				coords.y = paintY;
			}

			if (UISidebar.inst.splitView) {
				UISidebar.inst.viewIndex = -1;
			}

			if (lockBegin) {
				var dx = Math.abs(lockStartX - mouse.viewX);
				var dy = Math.abs(lockStartY - mouse.viewY);
				if (dx > 1 || dy > 1) {
					lockBegin = false;
					dx > dy ? lockY = true : lockX = true;
				}
			}

			var kb = iron.system.Input.getKeyboard();
			if (kb.started(Config.keymap.brush_ruler)) { lockStartX = mouse.viewX; lockStartY = mouse.viewY; lockBegin = true; }
			else if (kb.released(Config.keymap.brush_ruler)) { lockX = lockY = lockBegin = false; }

			if (UISidebar.inst.brushLazyRadius > 0) {
				var v1 = new Vec4(UISidebar.inst.brushLazyX, UISidebar.inst.brushLazyY, 0.0);
				var v2 = new Vec4(coords.x, coords.y, 0.0);
				var d = Vec4.distance(v1, v2);

				if (d > UISidebar.inst.brushLazyRadius / 10) {
					var v3 = new Vec4();
					v3.subvecs(v2, v1);
					v3.normalize();
					v3.mult(1.0 - UISidebar.inst.brushLazyStep);
					v3.mult(UISidebar.inst.brushLazyRadius / 10);
					v2.addvecs(v1, v3);
					coords.x = v2.x;
					coords.y = v2.y;
				}

				UISidebar.inst.lastPaintX = -1;
				UISidebar.inst.lastPaintY = -1;
			}
		});
	}

	override function get(from: Int): Dynamic {
		return coords;
	}
}
