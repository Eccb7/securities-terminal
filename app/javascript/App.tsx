import React from 'react';
import { Routes, Route } from 'react-router-dom';
import { Layout } from '@/components/layout/Layout';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';

// Lazy load pages for code splitting
const Dashboard = React.lazy(() => import('@/components/dashboard/Dashboard'));
const SecuritiesList = React.lazy(() => import('@/components/securities/SecuritiesList'));
const SecurityDetail = React.lazy(() => import('@/components/securities/SecurityDetail'));
const OrdersList = React.lazy(() => import('@/components/orders/OrdersList'));
const OrderForm = React.lazy(() => import('@/components/orders/OrderForm'));
const PortfoliosList = React.lazy(() => import('@/components/portfolios/PortfoliosList'));
const PortfolioDetail = React.lazy(() => import('@/components/portfolios/PortfolioDetail'));
const WatchlistsList = React.lazy(() => import('@/components/watchlists/WatchlistsList'));
const WatchlistDetail = React.lazy(() => import('@/components/watchlists/WatchlistDetail'));
const NewsFeed = React.lazy(() => import('@/components/news/NewsFeed'));
const NewsArticle = React.lazy(() => import('@/components/news/NewsArticle'));
const AlertsList = React.lazy(() => import('@/components/alerts/AlertsList'));

const App: React.FC = () => {
  return (
    <React.Suspense fallback={<LoadingSpinner />}>
      <Routes>
        {/* Dashboard - Home */}
        <Route
          path="/"
          element={
            <Layout>
              <Dashboard />
            </Layout>
          }
        />

        {/* Securities */}
        <Route
          path="/securities"
          element={
            <Layout>
              <SecuritiesList />
            </Layout>
          }
        />
        <Route
          path="/securities/:id"
          element={
            <Layout>
              <SecurityDetail />
            </Layout>
          }
        />

        {/* Orders */}
        <Route
          path="/orders"
          element={
            <Layout>
              <OrdersList />
            </Layout>
          }
        />
        <Route
          path="/orders/new"
          element={
            <Layout>
              <OrderForm />
            </Layout>
          }
        />

        {/* Portfolios */}
        <Route
          path="/portfolios"
          element={
            <Layout>
              <PortfoliosList />
            </Layout>
          }
        />
        <Route
          path="/portfolios/:id"
          element={
            <Layout>
              <PortfolioDetail />
            </Layout>
          }
        />

        {/* Watchlists */}
        <Route
          path="/watchlists"
          element={
            <Layout>
              <WatchlistsList />
            </Layout>
          }
        />
        <Route
          path="/watchlists/:id"
          element={
            <Layout>
              <WatchlistDetail />
            </Layout>
          }
        />

        {/* News */}
        <Route
          path="/news"
          element={
            <Layout>
              <NewsFeed />
            </Layout>
          }
        />
        <Route
          path="/news/:id"
          element={
            <Layout>
              <NewsArticle />
            </Layout>
          }
        />

        {/* Alerts */}
        <Route
          path="/alerts"
          element={
            <Layout>
              <AlertsList />
            </Layout>
          }
        />
      </Routes>
    </React.Suspense>
  );
};

export default App;
