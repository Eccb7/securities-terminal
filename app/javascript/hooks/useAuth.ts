import { useEffect } from 'react';
import { useAuthStore } from '@/stores/authStore';
import { authApi } from '@/services/api';

export const useAuth = () => {
  const { user, isLoading, setUser, setLoading, logout } = useAuthStore();

  useEffect(() => {
    // Fetch current user on mount
    const fetchUser = async () => {
      try {
        setLoading(true);
        const response = await authApi.getCurrentUser();
        setUser(response.data);
      } catch (error) {
        console.error('Failed to fetch user:', error);
        setUser(null);
      } finally {
        setLoading(false);
      }
    };

    if (user === null && isLoading) {
      fetchUser();
    }
  }, [user, isLoading, setUser, setLoading]);

  const signOut = async () => {
    try {
      await authApi.signOut();
      logout();
      window.location.href = '/users/sign_in';
    } catch (error) {
      console.error('Failed to sign out:', error);
    }
  };

  return {
    user,
    isLoading,
    isAuthenticated: !!user,
    signOut,
  };
};
