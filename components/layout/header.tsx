import ThemeToggle from '@/components/layout/ThemeToggle/theme-toggle';
import { cn } from '@/lib/utils';
import { MobileSidebar } from './mobile-sidebar';
import { UserNav } from './user-nav';

export default function Header() {
  return (
    <div className="supports-backdrop-blur:bg-background/60 fixed left-0 right-0 top-0 z-20 border-b bg-background/95 backdrop-blur">
      <nav className="flex h-14 items-center justify-between px-4">
        <div className="flex flex-row">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            className="mr-2 h-6 w-6"
          >
            <rect x="2" y="2" width="4" height="4" fill="black" />
            <rect x="8" y="2" width="4" height="4" fill="black" />
            <rect x="14" y="2" width="4" height="4" fill="black" />
            <rect x="2" y="8" width="4" height="4" fill="black" />
            {/*<rect x="8" y="8" width="4" height="4" fill="black" />*/}
            <rect x="14" y="8" width="4" height="4" fill="black" />
            <rect x="2" y="14" width="4" height="4" fill="black" />
            <rect x="8" y="14" width="4" height="4" fill="black" />
            {/*<rect x="14" y="14" width="4" height="4" fill="black" />*/}
            <rect x="16" y="16" width="6" height="6" fill="white" />
          </svg>
          <h1>Qrder</h1>
        </div>
        <div className={cn('block lg:!hidden')}>
          <MobileSidebar />
        </div>

        <div className="flex items-center gap-2">
          <UserNav />
          <ThemeToggle />
        </div>
      </nav>
    </div>
  );
}
