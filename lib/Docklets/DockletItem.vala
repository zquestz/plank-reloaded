//
//  Copyright (C) 2011 Robert Dyer
//
//  This file is part of Plank.
//
//  Plank is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Plank is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

namespace Plank
{
	public abstract class DockletItem : DockItem
	{
		construct
		{
			notify["Container"].connect (handle_container_changed);
		}

		void handle_container_changed ()
		{
			if (Container == null)
				removed_from_dock ();
		}

		/**
		 * Called when this docklet was removed from its dock.
		 *
		 * Disconnect handlers connected to external objects and stop timers
		 * or threads here. Cleanup must not rely solely on the destructor,
		 * because such references keep this item alive and unreachable for
		 * finalization.
		 */
		protected virtual void removed_from_dock ()
		{
		}

		public override bool is_valid ()
		{
			return true;
		}
	}
}
