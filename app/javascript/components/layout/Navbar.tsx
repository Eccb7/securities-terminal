import React from 'react';
import { Link } from 'react-router-dom';

export const Navbar: React.FC = () => {
  const handleSignOut = () => {
    // Use Rails logout route
    window.location.href = '/users/sign_out';
  };

  return (
    <nav className="bg-gray-900 text-white border-b border-gray-700">
      <div className="container mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <div className="flex items-center">
            <Link to="/" className="text-xl font-bold text-blue-400 hover:text-blue-300">
              Kenya Securities Terminal
            </Link>
          </div>

          {/* Navigation Links */}
          <div className="hidden md:flex items-center space-x-4">
            <Link
              to="/"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Dashboard
            </Link>
            <Link
              to="/securities"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Securities
            </Link>
            <Link
              to="/orders"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Orders
            </Link>
            <Link
              to="/portfolios"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Portfolios
            </Link>
            <Link
              to="/watchlists"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Watchlists
            </Link>
            <Link
              to="/news"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              News
            </Link>
            <Link
              to="/alerts"
              className="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-800 transition-colors"
            >
              Alerts
            </Link>
          </div>

          {/* User Menu */}
          <div className="flex items-center space-x-4">
            <button
              onClick={handleSignOut}
              className="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700 transition-colors"
            >
              Sign Out
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
